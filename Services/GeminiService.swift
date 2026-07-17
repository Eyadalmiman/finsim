import Foundation

// MARK: - Chat Message

struct AIChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case model
    }

    let id = UUID()
    let role: Role
    var text: String
}

// MARK: - Gemini Service

enum GeminiError: LocalizedError {
    case missingKey
    case badKey
    case server(String)
    case emptyReply

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "No Gemini API key is set up yet. Please check back later."
        case .badKey:
            return "The Gemini API key was rejected. Please check back later."
        case .server(let message):
            return message
        case .emptyReply:
            return "The AI didn't return a reply. Please try again."
        }
    }
}

enum GeminiService {
    /// The key lives in Secrets.swift (gitignored, byte-obfuscated) — see
    /// Secrets.swift.example for how to set up a new machine or a new key.
    static var apiKey: String { Secrets.geminiAPIKey }

    private static let model = "gemini-2.5-flash"

    /// The coach is "trained" on the app by prompting: the system instruction
    /// carries FinSim's feature map and the live Library catalog.
    private static var systemInstruction: String {
        let subjectList = Library.categories.map { category in
            "\(category): " + Library.subjects(in: category).map(\.title).joined(separator: ", ")
        }.joined(separator: "; ")

        return """
        You are the FinSim AI Money Coach — a friendly financial-literacy tutor built into FinSim, \
        a Saudi Arabian financial education app.

        ABOUT THE APP: FinSim teaches money skills through three experiences on the Home tab: \
        (1) Banking License — a simulated mobile bank where users safely practice everyday banking \
        (cards, transfers, bills); \
        (2) Investment — an investing game where users buy assets (Savings Account, Government Bonds, \
        Stocks, Real Estate, Startup, Crypto) that earn income every second, teaching compounding and \
        risk versus reward — higher-tier assets cost more and each purchase raises the next price; \
        (3) The Library — 24 reading subjects across 5 categories — \(subjectList). \
        The app also has Settings (English/Arabic, dark mode, notifications, biometric lock) and an \
        Account tab with progress badges (Saver, Scam Spotter, Investor). Users sign in with email, \
        Apple, or Google; Nafath sign-in is coming soon. The AI Coach (you) only works online.

        YOUR JOB: Answer questions about money — budgeting, saving, banking, credit, debt, investing, \
        Zakat, Islamic finance, scams, insurance, retirement — clearly and simply, using a Saudi \
        context where relevant (SAR, SAMA, SIMAH, Tadawul, GOSI, 15% VAT, Zakat and nisab, Murabaha, \
        sukuk, Takaful). When a Library subject covers the topic, point the user to it by name. Also \
        help users find their way around the app itself.

        RULES: You are an educational tool, not a licensed financial advisor. Never give personalized \
        investment recommendations or tell users what to buy or sell — explain concepts and trade-offs \
        instead, and say you can't give personal advice if pushed. Keep answers short (under about 150 \
        words) unless the user asks for depth. Use plain language and plain text only — no markdown \
        formatting of any kind (no asterisks, bold, headings, or tables). Reply in \
        Arabic when the user writes in Arabic. Be warm and encouraging. Politely decline questions \
        unrelated to money or FinSim.
        """
    }

    // MARK: Request / response payloads

    private struct Payload: Encodable {
        struct Part: Encodable { let text: String }
        struct Content: Encodable {
            var role: String? = nil
            let parts: [Part]
        }
        struct GenerationConfig: Encodable {
            let temperature: Double
            let maxOutputTokens: Int
        }

        let systemInstruction: Content
        let contents: [Content]
        let generationConfig: GenerationConfig

        enum CodingKeys: String, CodingKey {
            case systemInstruction = "system_instruction"
            case contents
            case generationConfig
        }
    }

    private struct Reply: Decodable {
        struct Candidate: Decodable {
            struct Content: Decodable {
                struct Part: Decodable { let text: String? }
                let parts: [Part]?
            }
            let content: Content?
        }
        struct APIError: Decodable {
            let code: Int?
            let message: String?
        }
        let candidates: [Candidate]?
        let error: APIError?
    }

    // MARK: API call

    static func reply(to conversation: [AIChatMessage], extraContext: String? = nil) async throws -> String {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw GeminiError.missingKey }

        var request = URLRequest(
            url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-goog-api-key")

        // Send only the recent turns; the system instruction carries the context.
        let history = conversation.suffix(20).map { message in
            Payload.Content(
                role: message.role == .user ? "user" : "model",
                parts: [.init(text: message.text)]
            )
        }

        var instruction = systemInstruction
        if appIsArabic {
            instruction += "\n\nThe app is currently set to Arabic — reply in Arabic unless the user writes in English."
        }
        if let extraContext {
            instruction += "\n\nCURRENT CONTEXT: \(extraContext)"
        }

        let payload = Payload(
            systemInstruction: .init(parts: [.init(text: instruction)]),
            contents: history,
            generationConfig: .init(temperature: 0.7, maxOutputTokens: 900)
        )
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        let reply = try? JSONDecoder().decode(Reply.self, from: data)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            if http.statusCode == 400 || http.statusCode == 401 || http.statusCode == 403 {
                throw GeminiError.badKey
            }
            throw GeminiError.server(reply?.error?.message ?? "The AI service returned an error (\(http.statusCode)). Please try again.")
        }

        guard
            let text = reply?.candidates?.first?.content?.parts?
                .compactMap(\.text)
                .joined(),
            !text.isEmpty
        else {
            throw GeminiError.emptyReply
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
