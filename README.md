<div align = "center"> <img src = "Pictures/App logo finsim.png" width = "250" alt = "FinSim" /> </div>



FinSim
Learn money by living it — safely.
A native iOS financial-literacy app that teaches you to bank, invest, and spot fraud inside a fully simulated environment, where every mistake is free.

Built with SwiftUI · Deep-green Liquid Glass design · Full Arabic RTL localization · Saudi-oriented (SAR · Zakat · Vision 2030)

<div align = "center"> <img src="Pictures/Home ENG.png" width="250" alt="Home screen" /> </div>

The problem
Traditional financial awareness relies on warnings people scroll past — and it fails. In our testing, 75% of users fell for an OTP phishing trap despite years of exposure to "never share your code" messages. People don't learn financial safety by reading about it; they learn by doing it. But there's no safe place to make those mistakes before real money is on the line.

What FinSim does
FinSim is that safe place: a simulated bank where the fraud is real-feeling but the losses are fictional. Users train against realistic scams, practice investing in a live-feeling market, and study a full library — all before opening their first real account.

Features
🏦 The Banking License — train against real fraud
A simulated banking app that throws real-world financial threats at you. Face an OTP phishing trap, a delivery-fee SMS scam, and more — make the wrong call and you "lose" virtual funds, then get an instant explanation of the trick. Scoring is deliberately unforgiving (25% penalty per mistake) so the lesson sticks.

<div align = "center"> <img src="Pictures/Bank Dashboard (BL).png" width="250" alt="Bank Dashboard" /> <img src="Pictures/OTP Phishing scam (BL).png" width="250" alt="OTP Phishing trap" /> <img src="Pictures/Safari customs Payment scam (BL).png" width="250" alt="SMS Scam" /> </div>

📈 The Investment game — a living market
Buy and sell assets across five risk tiers with cost-basis tracking, bulk buys, a 5% broker fee, offline earnings, and goals. Prices drift with a simulated market so you learn to buy dips and sell surges.

<div align = "center"> <img src="Pictures/Home (INV).png" width="250" alt="Investment Dashboard" /> <img src="Pictures/Invest (INV).png" width="250" alt="Invest in Assets" /> </div>

₿ A simulated crypto market — as close to real as it gets
Trade 8 real coins (BTC, ETH, SOL, BNB, XRP, ADA, DOGE, LTC) in a market that mimics real dynamics: regime switching (bull/bear/sideways), correlation to Bitcoin, turbulence clustering, and news-driven jumps. No income — pure price, just like the real thing.

<div align = "center"> <img src="Pictures/Crypto Market (INV).png" width="250" alt="Crypto market" /> <img src="Pictures/Bitcoin price (INV).png" width="250" alt="Bitcoin trade screen" /> </div>

📚 The Library — real content, measured learning
25 bilingual subjects from budgeting to Zakat to compounding. Each subject ends in a 3-question quiz — passing (2 of 3) completes it and earns you the Scholar badge, so learning is measured, not assumed.

<div align = "center"> <img src="Pictures/Library main screen (LIB).png" width="250" alt="Library table of contents" /> <img src="Pictures/Budgeting (LIB).png" width="250" alt="Budgeting article" /> </div>

🤖 AI Money Coach
A context-aware assistant (powered by Google Gemini) that knows what you're reading and answers your money questions in Arabic or English.

<div align = "center"> <img src="Pictures/AI money coach answer (LIB).png" width="250" alt="AI money coach in the Library" /> <img src="Pictures/Account.png" width="250" alt="Account page" /> </div>

Tech stack
| Area | Technology |
|---|---|
| Language & UI | Swift · SwiftUI (iOS 26) |
| Persistence | SwiftData (local-only, no cloud) |
| Design | Liquid Glass (.glassEffect), custom green pattern background |
| AI | Google Gemini API (AI Money Coach) |
| Media | AVFoundation (video splash screen) |
| Localization | Global tr() helper + full RTL, English ⇄ العربية |

FinSim is a native app with no backend you host — data lives on the device, and the only external call is to Gemini for the coach.

Getting started
Requirements: Xcode 26+, iOS 26 simulator or device.

```terminal
git clone https://github.com/Eyadalmiman/finsim/tree/main
cd FinSim
```

1. Add your secrets. The Gemini API key is intentionally kept out of git. Copy the template and fill in your key:

```terminal
cp FinSim/Services/Secrets.swift.example FinSim/Services/Secrets.swift
# edit FinSim/Services/Secrets.swift and add your Gemini API key
```

FinSim/Services/Secrets.swift is gitignored and never committed.

2. Build and run:

```terminal
open FinSim.xcodeproj
# select an iPhone simulator and press ⌘R
```

Or from the command line:

```xcode
xcodebuild -project FinSim.xcodeproj -scheme FinSim \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

Localization
FinSim is fully bilingual. Switch between English and العربية in Settings — the entire interface, including layout direction (RTL), rebuilds instantly.

<div align = "center"> <img src="Pictures/Home ENG.png" width="250" alt="Home screen ENG" /> <img src="Pictures/Home AR.png" width="250" alt="Home screen AR" /> </div>

Privacy
No real money, accounts, or transactions are ever involved. Account and progress data are stored locally on the device; the only data sent off-device is the text you type to the AI Money Coach (to Google's Gemini API). See the in-app About → Privacy Policy for details.

Built for a financial-literacy competition · Aligned with Saudi Vision 2030's financial-inclusion goals.

