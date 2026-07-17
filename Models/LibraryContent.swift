import Foundation

// MARK: - Library Content Model

struct LibrarySection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct LibrarySubject: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let category: String
    let summary: String
    let sections: [LibrarySection]

    static func == (lhs: LibrarySubject, rhs: LibrarySubject) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    /// The knowledge check that marks this subject as completed.
    var quiz: [QuizQuestion] { LibraryQuizzes.questions(for: id) }
}

// MARK: - Catalog
//
// The catalog is computed (not stored) so every string re-localizes through
// tr() when the app language changes. Subject `id`s are stable English slugs
// and are what gets persisted (read tracking), never the localized titles.

enum Library {
    static var categories: [String] {
        [
            tr("Money Basics", "أساسيات المال"),
            tr("Earning & Careers", "الدخل والمهن"),
            tr("Credit & Debt", "الائتمان والديون"),
            tr("Investing", "الاستثمار"),
            tr("Protection & Values", "الحماية والقيم")
        ]
    }

    static func subjects(in category: String) -> [LibrarySubject] {
        all.filter { $0.category == category }
    }

    /// Stable identifiers of every subject, independent of language.
    static var allSubjectIDs: [String] { all.map(\.id) }

    // The catalog holds ~200 localized strings, so it is built once per
    // language instead of on every access (the TOC reads it per keystroke).
    private static let catalogCache = LocalizedCache { buildCatalog() }

    static var all: [LibrarySubject] { catalogCache.value }

    private static func buildCatalog() -> [LibrarySubject] {
        [

        // ───────────────────────────── Money Basics ─────────────────────────────

        LibrarySubject(
            id: "what-is-money",
            title: tr("What Is Money?", "ما هو المال؟"),
            icon: "banknote",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("Where money came from and why it has value.", "من أين جاء المال ولماذا له قيمة."),
            sections: [
                LibrarySection(
                    title: tr("Before Money: Barter", "قبل المال: المقايضة"),
                    body: tr("Thousands of years ago people traded goods directly — a farmer swapped wheat for a fisherman's catch. Barter only works when both people want exactly what the other has, which made trade slow and hard. Money was invented to fix this problem.",
                             "قبل آلاف السنين كان الناس يتبادلون السلع مباشرة — المزارع يبادل قمحه بسمك الصياد. المقايضة لا تنجح إلا إذا أراد كل طرف ما يملكه الآخر بالضبط، مما جعل التجارة بطيئة وصعبة. اختُرع المال لحل هذه المشكلة.")),
                LibrarySection(
                    title: tr("What Makes Money, Money", "ما الذي يجعل المال مالاً"),
                    body: tr("Anything can be money if it does three jobs: it's a medium of exchange (everyone accepts it), a unit of account (prices can be measured in it), and a store of value (it keeps its worth over time). Gold coins, paper riyals, and the numbers in your banking app all do these three jobs.",
                             "أي شيء يمكن أن يكون مالاً إذا أدى ثلاث وظائف: وسيلة للتبادل (يقبله الجميع)، ووحدة للحساب (تُقاس به الأسعار)، ومخزن للقيمة (يحتفظ بقيمته مع الوقت). العملات الذهبية والريالات الورقية والأرقام في تطبيقك البنكي كلها تؤدي هذه الوظائف الثلاث.")),
                LibrarySection(
                    title: tr("Modern Money", "المال الحديث"),
                    body: tr("Today most money isn't paper at all — it's digital records kept by banks and central banks like the Saudi Central Bank (SAMA). When you tap your card, no cash moves; banks simply update their records. That's why protecting your accounts and passwords matters so much.",
                             "اليوم معظم المال ليس ورقياً أصلاً — بل سجلات رقمية تحتفظ بها البنوك والبنوك المركزية مثل البنك المركزي السعودي (ساما). عندما تمرر بطاقتك لا تتحرك أي نقود؛ البنوك ببساطة تحدّث سجلاتها. لهذا تُعد حماية حساباتك وكلمات مرورك بهذه الأهمية.")),
                LibrarySection(
                    title: tr("Why Money Has Value", "لماذا للمال قيمة"),
                    body: tr("A 100-riyal note costs almost nothing to print. It's valuable because everyone agrees it is, and because the government guarantees it can settle debts. This shared trust is the foundation of every economy — and it's why counterfeiting and fraud are treated so seriously.",
                             "طباعة ورقة المئة ريال لا تكلف شيئاً يُذكر. قيمتها تأتي من اتفاق الجميع على أنها ذات قيمة، ومن ضمان الحكومة أنها تسدد الديون. هذه الثقة المشتركة هي أساس كل اقتصاد — ولهذا يُعامل التزوير والاحتيال بهذه الصرامة."))
            ]
        ),

        LibrarySubject(
            id: "budgeting",
            title: tr("Budgeting", "إعداد الميزانية"),
            icon: "chart.pie",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("Give every riyal a job before you spend it.", "أعطِ كل ريال مهمة قبل أن تنفقه."),
            sections: [
                LibrarySection(
                    title: tr("What a Budget Is", "ما هي الميزانية"),
                    body: tr("A budget is simply a plan for your money: how much comes in, and where it goes. Without a plan, money tends to disappear on small things and nothing is left for what matters. With a plan, you decide in advance.",
                             "الميزانية ببساطة خطة لمالك: كم يدخل، وأين يذهب. بدون خطة يميل المال إلى الاختفاء في أشياء صغيرة ولا يبقى شيء لما يهم. مع الخطة، أنت من يقرر مسبقاً.")),
                LibrarySection(
                    title: tr("The 50/30/20 Rule", "قاعدة 50/30/20"),
                    body: tr("A simple starting point: spend about 50% of your income on needs (food, housing, transport), 30% on wants (entertainment, eating out), and put 20% into savings or paying off debt. The exact numbers matter less than having limits you actually follow.",
                             "نقطة بداية بسيطة: أنفق نحو 50٪ من دخلك على الاحتياجات (طعام، سكن، مواصلات)، و30٪ على الرغبات (ترفيه، مطاعم)، وضع 20٪ في الادخار أو سداد الديون. الأرقام الدقيقة أقل أهمية من وجود حدود تلتزم بها فعلاً.")),
                LibrarySection(
                    title: tr("Needs vs. Wants", "الاحتياجات مقابل الرغبات"),
                    body: tr("The hardest budgeting skill is honesty about the difference. You need lunch; you want the fancy restaurant. You need a phone; you may not need this year's newest model. Before any purchase, ask: 'If I wait a week, will I still want this?' Most impulse buys fail that test.",
                             "أصعب مهارة في الميزانية هي الصدق حول الفرق بينهما. أنت تحتاج الغداء؛ لكنك ترغب في المطعم الفاخر. تحتاج هاتفاً؛ وقد لا تحتاج أحدث إصدار هذا العام. قبل أي شراء اسأل نفسك: «إذا انتظرت أسبوعاً، هل سأظل أريده؟» معظم المشتريات الاندفاعية تفشل في هذا الاختبار.")),
                LibrarySection(
                    title: tr("Track, Then Adjust", "تابع ثم عدّل"),
                    body: tr("A budget isn't set once and forgotten. Track what you actually spend for a month — most people are shocked where their money goes. Then adjust the plan. Small leaks (a daily snack, a forgotten subscription) can quietly cost thousands of riyals a year.",
                             "الميزانية لا تُوضع مرة وتُنسى. تتبع ما تنفقه فعلياً لمدة شهر — معظم الناس يُصدمون أين تذهب أموالهم. ثم عدّل الخطة. التسريبات الصغيرة (وجبة خفيفة يومية، اشتراك منسي) قد تكلفك آلاف الريالات سنوياً دون أن تشعر."))
            ]
        ),

        LibrarySubject(
            id: "saving",
            title: tr("Saving Money", "ادخار المال"),
            icon: "archivebox",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("How to actually keep some of what you earn.", "كيف تحتفظ فعلاً بجزء مما تكسبه."),
            sections: [
                LibrarySection(
                    title: tr("Pay Yourself First", "ادفع لنفسك أولاً"),
                    body: tr("The most reliable saving trick: move money to savings the moment you receive income, before you spend anything. If you wait to save 'whatever is left', there is usually nothing left. Even 10% saved automatically beats 30% saved 'when possible'.",
                             "أنجح حيلة للادخار: حوّل المال إلى حساب الادخار فور استلام دخلك، قبل أن تنفق أي شيء. إذا انتظرت لتدخر «ما تبقى»، فلن يتبقى شيء غالباً. حتى 10٪ تُدخر تلقائياً أفضل من 30٪ تُدخر «عند الإمكان».")),
                LibrarySection(
                    title: tr("Make It Automatic", "اجعله تلقائياً"),
                    body: tr("Set up an automatic transfer from your main account to a savings account every payday. Automation removes willpower from the equation — the money is gone before you can spend it, and you quickly stop missing it.",
                             "فعّل تحويلاً تلقائياً من حسابك الرئيسي إلى حساب الادخار في كل يوم راتب. الأتمتة تزيل قوة الإرادة من المعادلة — يذهب المال قبل أن تتمكن من إنفاقه، وسرعان ما تتوقف عن افتقاده.")),
                LibrarySection(
                    title: tr("Short vs. Long-Term Goals", "أهداف قصيرة وطويلة المدى"),
                    body: tr("Separate your savings by goal: a new laptop in 6 months, a car in 3 years, a home someday. Short-term goals belong in safe, instant-access accounts. Long-term goals can go into investments that grow over years. Never invest money you'll need soon.",
                             "افصل مدخراتك حسب الهدف: حاسوب جديد خلال 6 أشهر، سيارة خلال 3 سنوات، منزل يوماً ما. الأهداف القصيرة مكانها حسابات آمنة يمكن الوصول إليها فوراً. أما الأهداف الطويلة فيمكن وضعها في استثمارات تنمو عبر السنين. لا تستثمر أبداً مالاً ستحتاجه قريباً.")),
                LibrarySection(
                    title: tr("The Power of Starting Young", "قوة البدء مبكراً"),
                    body: tr("Time is the most powerful force in saving. Someone who saves 500 SAR a month from age 20 will usually end up far richer than someone saving 1,500 SAR a month from age 40, thanks to compounding. Starting small today beats starting big later.",
                             "الوقت هو أقوى عامل في الادخار. من يدخر 500 ريال شهرياً منذ سن العشرين سينتهي غالباً أغنى بكثير ممن يدخر 1,500 ريال شهرياً منذ الأربعين، بفضل التراكم. البدء صغيراً اليوم يتفوق على البدء كبيراً لاحقاً."))
            ]
        ),

        LibrarySubject(
            id: "emergency-fund",
            title: tr("Emergency Funds", "صندوق الطوارئ"),
            icon: "cross.case",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("Your financial airbag for life's surprises.", "وسادتك المالية لمفاجآت الحياة."),
            sections: [
                LibrarySection(
                    title: tr("Why You Need One", "لماذا تحتاجه"),
                    body: tr("Cars break, phones fall, jobs end, people get sick. An emergency fund is money set aside only for genuine surprises, so a bad week doesn't become a debt spiral. It's the difference between an inconvenience and a crisis.",
                             "السيارات تتعطل، والهواتف تسقط، والوظائف تنتهي، والناس يمرضون. صندوق الطوارئ مال مخصص فقط للمفاجآت الحقيقية، حتى لا يتحول أسبوع سيئ إلى دوامة ديون. إنه الفرق بين إزعاج عابر وأزمة.")),
                LibrarySection(
                    title: tr("How Much Is Enough", "كم يكفي"),
                    body: tr("The classic target is 3–6 months of essential expenses (rent, food, transport, bills). That sounds like a lot — start with a first goal of 1,000 SAR, then one month of expenses, then build from there. Any cushion is better than none.",
                             "الهدف التقليدي هو 3–6 أشهر من المصاريف الأساسية (إيجار، طعام، مواصلات، فواتير). قد يبدو كثيراً — ابدأ بهدف أول قدره 1,000 ريال، ثم شهر واحد من المصاريف، ثم ابنِ من هناك. أي احتياط أفضل من لا شيء.")),
                LibrarySection(
                    title: tr("Where to Keep It", "أين تحتفظ به"),
                    body: tr("Emergency money must be safe and instantly available: a separate savings account is ideal. Don't invest it in stocks or crypto — the emergency might arrive exactly when markets are down. And keep it separate from daily spending so you're not tempted.",
                             "مال الطوارئ يجب أن يكون آمناً ومتاحاً فوراً: حساب ادخار منفصل هو الأمثل. لا تستثمره في الأسهم أو العملات الرقمية — فقد تأتي الحالة الطارئة تماماً عندما تكون الأسواق منخفضة. واحتفظ به بعيداً عن مصروفك اليومي حتى لا تُغرى به.")),
                LibrarySection(
                    title: tr("What Counts as an Emergency", "ما الذي يُعد طارئاً"),
                    body: tr("A hospital visit counts. A broken car you need for work counts. A sale on sneakers does not. Every time you're tempted, ask: is this unexpected, necessary, and urgent? If it's not all three, it's not an emergency — it's a want wearing a disguise.",
                             "زيارة المستشفى تُحسب. سيارة معطلة تحتاجها للعمل تُحسب. تخفيضات على الأحذية لا تُحسب. كلما شعرت بالإغراء اسأل: هل هذا غير متوقع وضروري وعاجل؟ إذا لم تجتمع الثلاثة معاً، فهو ليس طارئاً — بل رغبة متنكرة."))
            ]
        ),

        LibrarySubject(
            id: "banking",
            title: tr("Banking Basics", "أساسيات البنوك"),
            icon: "building.columns",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("Accounts, cards, transfers, and how banks work.", "الحسابات والبطاقات والتحويلات وكيف تعمل البنوك."),
            sections: [
                LibrarySection(
                    title: tr("What Banks Do", "ماذا تفعل البنوك"),
                    body: tr("Banks keep your money safe, move it (transfers, cards, payments), and lend it. They profit mainly from lending deposits at higher rates than they pay savers, and from fees. Understanding this helps you see banks as services to compare, not just places to store cash.",
                             "البنوك تحفظ أموالك، وتحرّكها (تحويلات، بطاقات، مدفوعات)، وتقرضها. وتربح أساساً من إقراض الودائع بمعدلات أعلى مما تدفعه للمدخرين، ومن الرسوم. فهم هذا يساعدك على رؤية البنوك كخدمات تقارن بينها، لا مجرد أماكن لتخزين النقود.")),
                LibrarySection(
                    title: tr("Types of Accounts", "أنواع الحسابات"),
                    body: tr("A current account is for daily spending — salary in, payments out. A savings account pays you profit or interest to keep money parked. Many people use both: current for the month's budget, savings for everything else.",
                             "الحساب الجاري للإنفاق اليومي — الراتب يدخل، والمدفوعات تخرج. حساب الادخار يدفع لك أرباحاً أو فوائد مقابل إبقاء المال فيه. كثيرون يستخدمون الاثنين: الجاري لميزانية الشهر، والادخار لكل ما عداها.")),
                LibrarySection(
                    title: tr("Debit vs. Credit Cards", "بطاقة الخصم مقابل البطاقة الائتمانية"),
                    body: tr("A debit card spends your own money instantly from your account. A credit card spends the bank's money that you must repay later — convenient and useful for building history, but dangerous if you can't pay the full balance monthly.",
                             "بطاقة الخصم (مدى) تنفق أموالك الخاصة فوراً من حسابك. البطاقة الائتمانية تنفق أموال البنك التي يجب أن تسددها لاحقاً — مريحة ومفيدة لبناء السجل الائتماني، لكنها خطيرة إذا لم تستطع سداد الرصيد كاملاً شهرياً.")),
                LibrarySection(
                    title: tr("Keeping Your Account Safe", "حماية حسابك"),
                    body: tr("Your bank will never call to ask for your password, full card number, or OTP codes. Anyone who does is a fraudster — no exceptions. Use strong unique passwords, enable biometric login, and review your transactions weekly so you spot anything strange early.",
                             "بنكك لن يتصل بك أبداً ليطلب كلمة مرورك أو رقم بطاقتك الكامل أو رموز التحقق. أي شخص يفعل ذلك محتال — بلا استثناءات. استخدم كلمات مرور قوية وفريدة، وفعّل الدخول بالبصمة، وراجع عملياتك أسبوعياً لتكتشف أي شيء غريب مبكراً."))
            ]
        ),

        LibrarySubject(
            id: "interest",
            title: tr("Interest & Compounding", "الفائدة والتراكم"),
            icon: "percent",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("The force that grows savings and inflates debts.", "القوة التي تنمّي المدخرات وتضخّم الديون."),
            sections: [
                LibrarySection(
                    title: tr("What Interest Is", "ما هي الفائدة"),
                    body: tr("Interest is the price of money over time. When you save or lend, you receive it; when you borrow, you pay it. A 5% annual rate means 100 SAR becomes 105 SAR in a year — or a 100 SAR debt becomes 105 SAR if unpaid.",
                             "الفائدة هي ثمن المال عبر الزمن. عندما تدخر أو تُقرض تحصل عليها؛ وعندما تقترض تدفعها. معدل 5٪ سنوياً يعني أن 100 ريال تصبح 105 ريالات خلال سنة — أو أن دين 100 ريال يصبح 105 إذا لم يُسدد.")),
                LibrarySection(
                    title: tr("Compound Growth", "النمو المركب"),
                    body: tr("Compounding means earning returns on your returns. Year one: 100 grows to 105. Year two: you earn 5% on 105, not 100. It seems tiny at first, then snowballs — at 7% a year, money doubles roughly every 10 years. Einstein allegedly called it the eighth wonder of the world.",
                             "التراكم يعني كسب عوائد على عوائدك. السنة الأولى: 100 تنمو إلى 105. السنة الثانية: تكسب 5٪ على 105 وليس على 100. يبدو ضئيلاً في البداية ثم يتدحرج ككرة الثلج — عند 7٪ سنوياً يتضاعف المال كل 10 سنوات تقريباً. يُنسب لأينشتاين قوله إنه الأعجوبة الثامنة في العالم.")),
                LibrarySection(
                    title: tr("The Rule of 72", "قاعدة الـ72"),
                    body: tr("Quick mental math: divide 72 by the annual return to estimate doubling time. At 6%, money doubles in ~12 years; at 12%, in ~6 years. It also works for debt — a card charging 24% doubles what you owe in about 3 years if you never pay.",
                             "حساب ذهني سريع: اقسم 72 على العائد السنوي لتقدير زمن المضاعفة. عند 6٪ يتضاعف المال في نحو 12 سنة؛ وعند 12٪ في نحو 6 سنوات. وتنطبق على الديون أيضاً — بطاقة تفرض 24٪ تضاعف ما تدين به خلال 3 سنوات تقريباً إذا لم تسدد أبداً.")),
                LibrarySection(
                    title: tr("Compounding Works Against Debtors", "التراكم يعمل ضد المدينين"),
                    body: tr("The same force that builds wealth for savers crushes borrowers who only pay minimums. Unpaid interest gets added to the debt, and next month you pay interest on the interest. This is why expensive debt should almost always be paid off before you start investing.",
                             "القوة نفسها التي تبني ثروة المدخرين تسحق المقترضين الذين يدفعون الحد الأدنى فقط. الفائدة غير المسددة تُضاف إلى الدين، وفي الشهر التالي تدفع فائدة على الفائدة. لهذا يجب سداد الديون المكلفة دائماً تقريباً قبل البدء في الاستثمار."))
            ]
        ),

        LibrarySubject(
            id: "inflation",
            title: tr("Inflation", "التضخم"),
            icon: "arrow.up.forward",
            category: tr("Money Basics", "أساسيات المال"),
            summary: tr("Why prices rise and your cash quietly shrinks.", "لماذا ترتفع الأسعار وتنكمش نقودك بصمت."),
            sections: [
                LibrarySection(
                    title: tr("What Inflation Is", "ما هو التضخم"),
                    body: tr("Inflation is the general rise of prices over time. If inflation is 3%, something that cost 100 SAR last year costs about 103 SAR now. Your money didn't change — its purchasing power did. The same note buys a little less every year.",
                             "التضخم هو الارتفاع العام للأسعار مع الوقت. إذا كان التضخم 3٪، فما كان يكلف 100 ريال العام الماضي يكلف نحو 103 ريالات الآن. نقودك لم تتغير — قوتها الشرائية هي التي تغيرت. الورقة نفسها تشتري أقل قليلاً كل عام.")),
                LibrarySection(
                    title: tr("Why It Happens", "لماذا يحدث"),
                    body: tr("Prices rise when demand outruns supply, when producing goods gets more expensive, or when too much money chases too few goods. Central banks try to keep inflation low and steady — around 2% — because both high inflation and falling prices damage economies.",
                             "ترتفع الأسعار عندما يتجاوز الطلب العرض، أو عندما يصبح إنتاج السلع أكثر تكلفة، أو عندما تطارد نقود كثيرة سلعاً قليلة. تحاول البنوك المركزية إبقاء التضخم منخفضاً ومستقراً — حول 2٪ — لأن التضخم المرتفع وانخفاض الأسعار كليهما يضران بالاقتصادات.")),
                LibrarySection(
                    title: tr("The Hidden Tax on Cash", "الضريبة الخفية على النقد"),
                    body: tr("Cash under a mattress loses value silently: at 3% inflation, 10,000 SAR today buys only about 7,400 SAR worth of goods in ten years. This is why long-term savings need to grow at least as fast as inflation — through profit-bearing accounts or investments.",
                             "النقود تحت الفراش تفقد قيمتها بصمت: عند تضخم 3٪، فإن 10,000 ريال اليوم لن تشتري بعد عشر سنوات إلا ما قيمته نحو 7,400 ريال. لهذا يجب أن تنمو المدخرات طويلة المدى بسرعة التضخم على الأقل — عبر حسابات مدرة للأرباح أو استثمارات.")),
                LibrarySection(
                    title: tr("Protecting Yourself", "كيف تحمي نفسك"),
                    body: tr("You can't stop inflation, but you can outpace it. Keep only near-term money in cash; invest long-term money in assets that historically beat inflation, like diversified stock funds and real estate. Also, revisit your budget yearly — costs creep even when your salary doesn't.",
                             "لا يمكنك إيقاف التضخم، لكن يمكنك التفوق عليه. احتفظ نقداً بالمال قريب الاستخدام فقط؛ واستثمر مال المدى الطويل في أصول تتفوق تاريخياً على التضخم، مثل صناديق الأسهم المتنوعة والعقارات. وراجع ميزانيتك سنوياً — التكاليف تزحف حتى عندما لا يرتفع راتبك."))
            ]
        ),

        // ─────────────────────────── Earning & Careers ───────────────────────────

        LibrarySubject(
            id: "income",
            title: tr("Income & Salaries", "الدخل والرواتب"),
            icon: "briefcase",
            category: tr("Earning & Careers", "الدخل والمهن"),
            summary: tr("Understanding paychecks, benefits, and growing your income.", "فهم الرواتب والمزايا وتنمية دخلك."),
            sections: [
                LibrarySection(
                    title: tr("Gross vs. Net", "الإجمالي مقابل الصافي"),
                    body: tr("Your gross salary is the headline number; your net salary is what actually lands in your account after deductions like GOSI contributions. Always budget with the net number — planning around gross is how people end up short every month.",
                             "راتبك الإجمالي هو الرقم المعلن؛ وراتبك الصافي هو ما يصل فعلاً إلى حسابك بعد الاستقطاعات مثل اشتراكات التأمينات الاجتماعية. خطط دائماً بالرقم الصافي — التخطيط على الإجمالي هو ما يجعل الناس في عجز آخر كل شهر.")),
                LibrarySection(
                    title: tr("More Than the Salary", "أكثر من الراتب"),
                    body: tr("A job's real value includes housing and transport allowances, medical insurance, bonuses, training, and end-of-service benefits. A slightly lower salary with great benefits and learning opportunities often beats a higher one with none.",
                             "القيمة الحقيقية للوظيفة تشمل بدلات السكن والمواصلات، والتأمين الطبي، والمكافآت، والتدريب، ومكافأة نهاية الخدمة. راتب أقل قليلاً مع مزايا ممتازة وفرص تعلم يتفوق غالباً على راتب أعلى بدونها.")),
                LibrarySection(
                    title: tr("Growing Your Income", "تنمية دخلك"),
                    body: tr("Budgeting protects money you have; skills multiply money you'll earn. Certifications, languages, and in-demand skills (technology, sales, finance) raise your market value. The best investment most young people can make is in their own abilities.",
                             "الميزانية تحمي المال الذي تملكه؛ والمهارات تضاعف المال الذي ستكسبه. الشهادات واللغات والمهارات المطلوبة (التقنية، المبيعات، المالية) ترفع قيمتك في السوق. أفضل استثمار يمكن لمعظم الشباب القيام به هو في قدراتهم.")),
                LibrarySection(
                    title: tr("Negotiation Basics", "أساسيات التفاوض"),
                    body: tr("Salaries are often negotiable, especially with a competing offer or proven results. Research typical pay for the role, list what you've delivered, and ask confidently but respectfully. A 10% higher starting salary compounds through every future raise calculated on top of it.",
                             "الرواتب قابلة للتفاوض غالباً، خصوصاً مع عرض منافس أو نتائج مثبتة. ابحث عن الأجر المعتاد للوظيفة، واذكر ما أنجزته، واطلب بثقة واحترام. راتب بداية أعلى بـ10٪ يتراكم عبر كل زيادة مستقبلية تُحسب فوقه."))
            ]
        ),

        LibrarySubject(
            id: "entrepreneurship",
            title: tr("Side Hustles & Business", "العمل الإضافي والمشاريع"),
            icon: "lightbulb",
            category: tr("Earning & Careers", "الدخل والمهن"),
            summary: tr("Turning skills and ideas into extra income.", "تحويل المهارات والأفكار إلى دخل إضافي."),
            sections: [
                LibrarySection(
                    title: tr("Why a Side Income", "لماذا دخل إضافي"),
                    body: tr("A second income stream speeds up savings goals and protects you if your main income stops. It can be small — tutoring, design, reselling, content creation — and grow from there. Many large businesses started as weekend projects.",
                             "مصدر دخل ثانٍ يسرّع أهداف الادخار ويحميك إذا توقف دخلك الرئيسي. يمكن أن يكون صغيراً — تدريس خصوصي، تصميم، إعادة بيع، صناعة محتوى — وينمو من هناك. كثير من الشركات الكبرى بدأت كمشاريع نهاية أسبوع.")),
                LibrarySection(
                    title: tr("Start Small, Prove Demand", "ابدأ صغيراً وأثبت الطلب"),
                    body: tr("Don't spend big before anyone has paid you. Sell a simple version first: one client, one product, one weekend market stall. Real customers teach you more than months of planning. If nobody will pay for the small version, the big version won't work either.",
                             "لا تنفق كثيراً قبل أن يدفع لك أحد. بع نسخة بسيطة أولاً: عميل واحد، منتج واحد، بسطة في سوق نهاية الأسبوع. العملاء الحقيقيون يعلمونك أكثر من شهور من التخطيط. إذا لم يدفع أحد للنسخة الصغيرة، فلن تنجح النسخة الكبيرة أيضاً.")),
                LibrarySection(
                    title: tr("Keep Business Money Separate", "افصل مال المشروع عن مالك"),
                    body: tr("From day one, separate business money from personal money — a different account at minimum. Mixing them hides whether you're actually profitable and turns tax time into a nightmare. Track every riyal in and out, even for a tiny hustle.",
                             "من اليوم الأول، افصل مال المشروع عن المال الشخصي — بحساب مختلف على الأقل. خلطهما يخفي عنك ما إذا كنت رابحاً فعلاً ويحول موسم الالتزامات إلى كابوس. تتبع كل ريال يدخل ويخرج، حتى لأصغر مشروع.")),
                LibrarySection(
                    title: tr("Know the Rules", "اعرف الأنظمة"),
                    body: tr("In Saudi Arabia, freelancing and small businesses have official channels — freelance permits, commercial registration, and platforms like Maroof for online stores. Operating legally protects you, builds customer trust, and lets the business grow without fear.",
                             "في السعودية، للعمل الحر والمشاريع الصغيرة قنوات رسمية — وثائق العمل الحر، والسجل التجاري، ومنصات مثل «معروف» للمتاجر الإلكترونية. العمل النظامي يحميك، ويبني ثقة العملاء، ويتيح للمشروع النمو دون خوف."))
            ]
        ),

        LibrarySubject(
            id: "taxes-zakat",
            title: tr("Taxes & Zakat", "الضرائب والزكاة"),
            icon: "doc.text",
            category: tr("Earning & Careers", "الدخل والمهن"),
            summary: tr("VAT, Zakat, and the money you owe society.", "ضريبة القيمة المضافة والزكاة وما تدين به للمجتمع."),
            sections: [
                LibrarySection(
                    title: tr("VAT: The Tax You See Daily", "القيمة المضافة: الضريبة التي تراها يومياً"),
                    body: tr("Saudi Arabia charges Value Added Tax (currently 15%) on most goods and services — it's built into the price at checkout. A 100 SAR item includes about 13 SAR of VAT. Knowing this helps you understand real costs and read receipts properly.",
                             "تفرض السعودية ضريبة القيمة المضافة (حالياً 15٪) على معظم السلع والخدمات — وهي مدمجة في السعر عند الدفع. سلعة بـ100 ريال تتضمن نحو 13 ريالاً ضريبة. معرفة هذا تساعدك على فهم التكاليف الحقيقية وقراءة الفواتير بشكل صحيح.")),
                LibrarySection(
                    title: tr("What Zakat Is", "ما هي الزكاة"),
                    body: tr("Zakat is one of the pillars of Islam: an annual obligation of 2.5% on wealth held above a minimum threshold (nisab) for a full lunar year. It applies to savings, gold, business inventory, and some investments — purifying wealth by sharing it with those in need.",
                             "الزكاة ركن من أركان الإسلام: التزام سنوي بنسبة 2.5٪ على الثروة التي تتجاوز حداً أدنى (النصاب) وحال عليها الحول. تشمل المدخرات والذهب وبضائع التجارة وبعض الاستثمارات — تطهيراً للمال بمشاركته مع المحتاجين.")),
                LibrarySection(
                    title: tr("Calculating Zakat Simply", "حساب الزكاة ببساطة"),
                    body: tr("Add up zakatable wealth held a full year — cash, savings, gold, trade goods. If it exceeds the nisab (pegged to the value of 85 grams of gold), you owe 2.5% of it. Someone holding 40,000 SAR in savings all year owes 1,000 SAR of Zakat.",
                             "اجمع الثروة الزكوية التي حال عليها الحول — نقد، مدخرات، ذهب، عروض تجارة. إذا تجاوزت النصاب (المرتبط بقيمة 85 غراماً من الذهب) وجبت فيها 2.5٪. من يحتفظ بـ40,000 ريال مدخرات طوال العام عليه 1,000 ريال زكاة.")),
                LibrarySection(
                    title: tr("Plan for What You Owe", "خطط لما عليك"),
                    body: tr("Whether it's Zakat, business taxes, or VAT you collect from customers, treat owed money as never yours. Set it aside as it accrues instead of scrambling at year end. A simple separate account for obligations keeps you honest and stress-free.",
                             "سواء كانت زكاة أو ضرائب أعمال أو قيمة مضافة تحصّلها من عملائك، عامل المال المستحق كأنه ليس لك أصلاً. اعزله أولاً بأول بدلاً من التخبط آخر العام. حساب منفصل بسيط للالتزامات يبقيك أميناً ومرتاح البال."))
            ]
        ),

        // ───────────────────────────── Credit & Debt ─────────────────────────────

        LibrarySubject(
            id: "credit",
            title: tr("Credit & Credit Scores", "الائتمان والسجل الائتماني"),
            icon: "creditcard",
            category: tr("Credit & Debt", "الائتمان والديون"),
            summary: tr("How borrowing history follows you — via SIMAH and beyond.", "كيف يلاحقك تاريخ اقتراضك — عبر سمة وغيرها."),
            sections: [
                LibrarySection(
                    title: tr("What Credit Is", "ما هو الائتمان"),
                    body: tr("Credit is borrowed money you promise to repay, usually with an added cost. Cards, car financing, and phone installment plans are all credit. Used carefully it's a tool; used carelessly it becomes a trap that eats future income.",
                             "الائتمان مال مقترض تتعهد بسداده، عادة بتكلفة إضافية. البطاقات وتمويل السيارات وخطط تقسيط الهواتف كلها ائتمان. مستخدماً بحذر يكون أداة؛ ومستخدماً بتهور يصبح فخاً يلتهم دخلك المستقبلي.")),
                LibrarySection(
                    title: tr("Your Credit Record", "سجلك الائتماني"),
                    body: tr("In Saudi Arabia, SIMAH (the national credit bureau) records your borrowing and repayment history. Banks check it before approving financing. Late payments and defaults stay on your record for years and can block you from car loans, mortgages, and even some jobs.",
                             "في السعودية، تسجل «سمة» (الشركة السعودية للمعلومات الائتمانية) تاريخ اقتراضك وسدادك. تتحقق البنوك منه قبل الموافقة على التمويل. المدفوعات المتأخرة والتعثر تبقى في سجلك لسنوات وقد تحرمك من تمويل سيارة أو عقار وحتى من بعض الوظائف.")),
                LibrarySection(
                    title: tr("Building Good History", "بناء سجل جيد"),
                    body: tr("Pay every bill and installment on time — set autopay so you can't forget. Keep card balances low relative to their limits, and don't apply for many products at once. Good history takes years to build and one bad season to damage.",
                             "سدد كل فاتورة وقسط في موعده — فعّل السداد التلقائي حتى لا تنسى. أبقِ أرصدة بطاقاتك منخفضة نسبةً إلى حدودها، ولا تتقدم لمنتجات كثيرة دفعة واحدة. السجل الجيد يحتاج سنوات ليُبنى وموسماً سيئاً واحداً ليتضرر.")),
                LibrarySection(
                    title: tr("The Minimum Payment Trap", "فخ الحد الأدنى للسداد"),
                    body: tr("Card statements show a tempting 'minimum payment' — often 5% of the balance. Paying only that means the rest keeps growing with fees. A 10,000 SAR balance repaid by minimums can take many years and cost thousands extra. Always aim to pay in full.",
                             "كشوف البطاقات تعرض «حداً أدنى للسداد» مغرياً — غالباً 5٪ من الرصيد. دفعه وحده يعني أن الباقي يستمر في النمو مع الرسوم. رصيد 10,000 ريال يُسدد بالحد الأدنى قد يستغرق سنوات طويلة ويكلف آلافاً إضافية. اسعَ دائماً للسداد الكامل."))
            ]
        ),

        LibrarySubject(
            id: "loans",
            title: tr("Loans & Mortgages", "القروض والتمويل العقاري"),
            icon: "house.lodge",
            category: tr("Credit & Debt", "الائتمان والديون"),
            summary: tr("Borrowing for cars and homes without drowning.", "الاقتراض للسيارات والمنازل دون غرق."),
            sections: [
                LibrarySection(
                    title: tr("Good Debt vs. Bad Debt", "الدين الجيد مقابل الدين السيئ"),
                    body: tr("Debt that buys appreciating assets or earning power (a home, education, business equipment) can be reasonable. Debt for vanishing things — vacations, gadgets, lifestyle — is almost always a mistake. Before borrowing ask: will this be worth more than the total I'll repay?",
                             "الدين الذي يشتري أصولاً تنمو قيمتها أو قدرة على الكسب (منزل، تعليم، معدات عمل) قد يكون معقولاً. أما الدين لأشياء زائلة — إجازات، أجهزة، مظاهر — فهو خطأ دائماً تقريباً. قبل الاقتراض اسأل: هل سيساوي هذا أكثر من إجمالي ما سأسدده؟")),
                LibrarySection(
                    title: tr("How Financing Works Here", "كيف يعمل التمويل هنا"),
                    body: tr("Saudi banks offer Sharia-compliant structures like Murabaha (the bank buys the item and sells it to you at a marked-up price paid in installments) and Ijara (lease-to-own). The markup replaces interest, but the core rule is the same: the total you repay exceeds the price.",
                             "تقدم البنوك السعودية هياكل متوافقة مع الشريعة مثل المرابحة (يشتري البنك السلعة ويبيعها لك بسعر أعلى يُدفع أقساطاً) والإجارة (تأجير منتهٍ بالتمليك). هامش الربح يحل محل الفائدة، لكن القاعدة الأساسية واحدة: إجمالي ما تسدده يتجاوز السعر.")),
                LibrarySection(
                    title: tr("The Real Cost of a Loan", "التكلفة الحقيقية للقرض"),
                    body: tr("Compare loans by APR (annual percentage rate) and by total repayment, not monthly installment. A longer term shrinks the monthly payment but grows the total cost dramatically. A 300,000 SAR mortgage over 25 years can cost far more than the house's price tag.",
                             "قارن القروض بمعدل النسبة السنوي وبإجمالي السداد، لا بالقسط الشهري. المدة الأطول تقلص القسط الشهري لكنها تضخم التكلفة الإجمالية بشكل كبير. تمويل عقاري بـ300,000 ريال على 25 عاماً قد يكلف أكثر بكثير من سعر المنزل نفسه.")),
                LibrarySection(
                    title: tr("Borrow Within Limits", "اقترض ضمن حدودك"),
                    body: tr("A common rule: total debt payments should stay under a third of your net income — Saudi regulations cap deductions similarly. Leave room for savings and surprises. Being approved for a loan doesn't mean you can afford it; banks approve based on repayment ability, not your life goals.",
                             "قاعدة شائعة: يجب أن تبقى أقساط الديون الإجمالية أقل من ثلث دخلك الصافي — والأنظمة السعودية تحد الاستقطاعات بنحو مشابه. اترك مجالاً للادخار والمفاجآت. موافقة البنك على قرضك لا تعني أنك قادر على تحمله؛ فالبنوك توافق بناءً على قدرتك على السداد، لا على أهداف حياتك."))
            ]
        ),

        LibrarySubject(
            id: "debt-management",
            title: tr("Getting Out of Debt", "الخروج من الديون"),
            icon: "figure.walk.arrival",
            category: tr("Credit & Debt", "الائتمان والديون"),
            summary: tr("Practical strategies to pay off what you owe.", "استراتيجيات عملية لسداد ما عليك."),
            sections: [
                LibrarySection(
                    title: tr("Face the Numbers", "واجه الأرقام"),
                    body: tr("The first step is a full list: every debt, its balance, its rate, its minimum payment. Most people avoid this and let anxiety win. Written down, most debt situations are more fixable than they feel — and you can't plan an escape from a maze you won't look at.",
                             "الخطوة الأولى قائمة كاملة: كل دين، ورصيده، ومعدله، وحده الأدنى. معظم الناس يتجنبون هذا ويتركون القلق ينتصر. حين تُكتب، تبدو معظم أوضاع الديون أكثر قابلية للإصلاح مما تشعر — ولا يمكنك تخطيط الهروب من متاهة ترفض النظر إليها.")),
                LibrarySection(
                    title: tr("Avalanche vs. Snowball", "الانهيار مقابل كرة الثلج"),
                    body: tr("Two proven methods: the avalanche pays minimums on everything and attacks the highest-rate debt first (cheapest mathematically). The snowball attacks the smallest balance first (fastest wins, best motivation). Pick the one you'll actually stick to.",
                             "طريقتان مجربتان: «الانهيار» يدفع الحد الأدنى لكل الديون ويهاجم الدين ذا المعدل الأعلى أولاً (الأرخص حسابياً). و«كرة الثلج» تهاجم أصغر رصيد أولاً (انتصارات أسرع وتحفيز أفضل). اختر الطريقة التي ستلتزم بها فعلاً.")),
                LibrarySection(
                    title: tr("Stop Digging", "توقف عن الحفر"),
                    body: tr("While paying off debt, freeze the borrowing: no new cards, no new installments, no 'buy now, pay later'. Cut expenses temporarily and throw everything extra at the debt. It's a season of discipline, not a permanent lifestyle — but it only works if the hole stops deepening.",
                             "أثناء سداد الديون جمّد الاقتراض: لا بطاقات جديدة ولا أقساط جديدة ولا «اشترِ الآن وادفع لاحقاً». قلص المصاريف مؤقتاً وارمِ كل فائض على الدين. إنه موسم انضباط لا أسلوب حياة دائم — لكنه لا ينجح إلا إذا توقفت الحفرة عن التعمق.")),
                LibrarySection(
                    title: tr("When to Ask for Help", "متى تطلب المساعدة"),
                    body: tr("If you can't cover minimums, contact your bank early — restructuring options exist, and banks prefer repayment plans over defaults. Hiding from calls makes everything worse. There's no shame in a repair plan; the shame would be pretending until it collapses.",
                             "إذا عجزت عن تغطية الحدود الدنيا فتواصل مع بنكك مبكراً — خيارات إعادة الجدولة موجودة، والبنوك تفضل خطط السداد على التعثر. الاختباء من الاتصالات يزيد كل شيء سوءاً. لا عيب في خطة إصلاح؛ العيب هو التظاهر حتى الانهيار."))
            ]
        ),

        // ─────────────────────────────── Investing ───────────────────────────────

        LibrarySubject(
            id: "investing-basics",
            title: tr("Investing Basics", "أساسيات الاستثمار"),
            icon: "chart.line.uptrend.xyaxis",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Making your money work while you sleep.", "اجعل مالك يعمل وأنت نائم."),
            sections: [
                LibrarySection(
                    title: tr("Saving vs. Investing", "الادخار مقابل الاستثمار"),
                    body: tr("Saving stores money safely for the near future. Investing puts money into assets — shares, property, funds — that can grow (or shrink) over years. Savings protect you from surprises; investments protect you from inflation and build long-term wealth. You need both.",
                             "الادخار يخزن المال بأمان للمستقبل القريب. الاستثمار يضع المال في أصول — أسهم، عقارات، صناديق — يمكن أن تنمو (أو تنكمش) عبر السنين. المدخرات تحميك من المفاجآت؛ والاستثمارات تحميك من التضخم وتبني الثروة طويلة المدى. أنت تحتاج كليهما.")),
                LibrarySection(
                    title: tr("Risk and Return", "المخاطرة والعائد"),
                    body: tr("The iron law of investing: higher potential returns always come with higher risk. Anything promising big profits with no risk is a lie. Your job isn't avoiding risk entirely — it's taking sensible risks you understand, with money you won't need soon.",
                             "القانون الحديدي للاستثمار: العوائد المحتملة الأعلى تأتي دائماً مع مخاطر أعلى. أي شيء يعد بأرباح كبيرة بلا مخاطرة كذبة. مهمتك ليست تجنب المخاطرة كلياً — بل خوض مخاطر معقولة تفهمها، بمال لن تحتاجه قريباً.")),
                LibrarySection(
                    title: tr("Time in the Market", "الوقت في السوق"),
                    body: tr("Markets swing daily, but historically trend upward over decades. Trying to jump in and out at the perfect moments fails even for professionals. Boring consistency — investing a fixed amount monthly regardless of headlines — beats clever timing for almost everyone.",
                             "الأسواق تتأرجح يومياً، لكنها تاريخياً تتجه صعوداً عبر العقود. محاولة الدخول والخروج في اللحظات المثالية تفشل حتى مع المحترفين. الاستمرارية المملة — استثمار مبلغ ثابت شهرياً بغض النظر عن العناوين — تتفوق على التوقيت الذكي لدى الجميع تقريباً.")),
                LibrarySection(
                    title: tr("Before You Invest", "قبل أن تستثمر"),
                    body: tr("Get the foundations right first: an emergency fund in place, expensive debt paid off, and money you won't touch for at least five years. Then start simple with diversified funds rather than picking individual winners. Complexity can come later — or never; simple works.",
                             "رتب الأساسيات أولاً: صندوق طوارئ جاهز، وديون مكلفة مسددة، ومال لن تلمسه خمس سنوات على الأقل. ثم ابدأ ببساطة بصناديق متنوعة بدلاً من انتقاء رابحين فرديين. التعقيد يمكن أن يأتي لاحقاً — أو لا يأتي أبداً؛ البساطة تنجح."))
            ]
        ),

        LibrarySubject(
            id: "stocks",
            title: tr("The Stock Market", "سوق الأسهم"),
            icon: "chart.bar",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Owning slices of companies, from Tadawul to Wall Street.", "امتلاك حصص من الشركات، من تداول إلى وول ستريت."),
            sections: [
                LibrarySection(
                    title: tr("What a Share Is", "ما هو السهم"),
                    body: tr("A share is a small ownership slice of a real company. Own Aramco or Apple shares and you own a piece of those businesses — entitled to a share of profits (dividends) and a vote at shareholder meetings. You profit if the company grows; you lose if it stumbles.",
                             "السهم حصة ملكية صغيرة في شركة حقيقية. امتلك أسهماً في أرامكو أو أبل وأنت تملك جزءاً من هذه الشركات — لك نصيب من الأرباح الموزعة وصوت في اجتماعات المساهمين. تربح إذا نمت الشركة؛ وتخسر إذا تعثرت.")),
                LibrarySection(
                    title: tr("How Prices Move", "كيف تتحرك الأسعار"),
                    body: tr("Share prices move with supply and demand: expectations of future profits, news, interest rates, and human emotion. Daily moves are mostly noise. Long-term, prices tend to follow real business performance — which is why patient owners of good businesses do well.",
                             "تتحرك أسعار الأسهم مع العرض والطلب: توقعات الأرباح المستقبلية، والأخبار، وأسعار الفائدة، ومشاعر البشر. التحركات اليومية ضجيج في معظمها. وعلى المدى الطويل تميل الأسعار لملاحقة الأداء الحقيقي للشركات — ولهذا ينجح الملاك الصبورون للشركات الجيدة.")),
                LibrarySection(
                    title: tr("Tadawul: The Saudi Market", "تداول: السوق السعودية"),
                    body: tr("The Saudi Exchange (Tadawul) is among the world's largest markets, home to Aramco, Al Rajhi Bank, SABIC and hundreds more. You invest through a licensed broker linked to your bank. Many companies also distribute regular dividends — cash paid per share you own.",
                             "السوق المالية السعودية (تداول) من أكبر أسواق العالم، وتضم أرامكو ومصرف الراجحي وسابك ومئات غيرها. تستثمر عبر وسيط مرخص مرتبط ببنكك. كثير من الشركات توزع أيضاً أرباحاً دورية — نقد يُدفع عن كل سهم تملكه.")),
                LibrarySection(
                    title: tr("Common Beginner Mistakes", "أخطاء المبتدئين الشائعة"),
                    body: tr("Putting everything in one hot stock, buying because prices already rose, panic-selling when they fall, and trading constantly on tips. The fix for all of them: diversify across many companies, invest on a schedule, and judge results over years, not days.",
                             "وضع كل شيء في سهم رائج واحد، والشراء لأن الأسعار ارتفعت بالفعل، والبيع بذعر عند هبوطها، والتداول المستمر بناءً على نصائح. علاج كل ذلك: نوّع عبر شركات كثيرة، واستثمر وفق جدول ثابت، واحكم على النتائج بالسنوات لا بالأيام."))
            ]
        ),

        LibrarySubject(
            id: "funds",
            title: tr("Funds & ETFs", "الصناديق وصناديق المؤشرات"),
            icon: "square.stack.3d.up",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Instant diversification in a single purchase.", "تنويع فوري في عملية شراء واحدة."),
            sections: [
                LibrarySection(
                    title: tr("The Basket Idea", "فكرة السلة"),
                    body: tr("A fund pools money from many investors to buy dozens or hundreds of assets at once. Buying one fund unit can make you a part-owner of 500 companies instantly. This diversification means no single company's failure can sink you.",
                             "الصندوق يجمع أموال مستثمرين كثيرين لشراء عشرات أو مئات الأصول دفعة واحدة. شراء وحدة صندوق واحدة قد يجعلك مالكاً جزئياً في 500 شركة فوراً. هذا التنويع يعني أن فشل شركة واحدة لا يمكن أن يغرقك.")),
                LibrarySection(
                    title: tr("Index Funds & ETFs", "صناديق المؤشرات والصناديق المتداولة"),
                    body: tr("Index funds simply copy a market index — like the Tadawul index or the S&P 500 — instead of paying managers to guess winners. ETFs are funds that trade like shares. Their superpower is cost: tiny fees, and decades of evidence that they beat most professional stock-pickers.",
                             "صناديق المؤشرات تنسخ مؤشر سوق ببساطة — مثل مؤشر تداول أو S&P 500 — بدلاً من دفع أجور مديرين يخمنون الرابحين. الصناديق المتداولة (ETFs) صناديق تُتداول كالأسهم. قوتها الخارقة في التكلفة: رسوم ضئيلة، وعقود من الأدلة على تفوقها على معظم المحترفين.")),
                LibrarySection(
                    title: tr("Why Fees Matter So Much", "لماذا الرسوم مهمة لهذه الدرجة"),
                    body: tr("A 2% annual fee sounds small but compounds viciously: over 30 years it can consume a third of your final wealth compared to a 0.2% fund. Always check the expense ratio before investing. Low costs are the most reliable predictor of good fund performance.",
                             "رسم سنوي 2٪ يبدو صغيراً لكنه يتراكم بشراسة: خلال 30 عاماً قد يلتهم ثلث ثروتك النهائية مقارنة بصندوق برسوم 0.2٪. تحقق دائماً من نسبة المصاريف قبل الاستثمار. التكاليف المنخفضة هي المؤشر الأكثر موثوقية لأداء الصناديق الجيد.")),
                LibrarySection(
                    title: tr("Choosing Your First Fund", "اختيار صندوقك الأول"),
                    body: tr("Look for: broad diversification (hundreds of holdings), low fees, and — if it matters to you — Sharia-compliant screening, which several Saudi and global funds offer. One good diversified fund, bought monthly for years, is a complete beginner strategy by itself.",
                             "ابحث عن: تنويع واسع (مئات الأصول)، ورسوم منخفضة، و— إن كان يهمك — فحص التوافق مع الشريعة الذي توفره عدة صناديق سعودية وعالمية. صندوق متنوع جيد واحد، يُشترى شهرياً لسنوات، استراتيجية مبتدئ كاملة بذاته."))
            ]
        ),

        LibrarySubject(
            id: "sukuk-bonds",
            title: tr("Bonds & Sukuk", "السندات والصكوك"),
            icon: "doc.plaintext",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Steadier returns from lending and asset-backed certificates.", "عوائد أكثر استقراراً من الإقراض والشهادات المدعومة بأصول."),
            sections: [
                LibrarySection(
                    title: tr("What Bonds Are", "ما هي السندات"),
                    body: tr("A bond is a loan you give to a government or company. They pay you regular coupons and return the full amount at maturity. Bonds usually swing less than stocks, which makes them the stabilizer in a portfolio — especially valuable closer to retirement.",
                             "السند قرض تمنحه لحكومة أو شركة. يدفعون لك كوبونات دورية ويعيدون المبلغ كاملاً عند الاستحقاق. تتأرجح السندات عادة أقل من الأسهم، مما يجعلها عامل الاستقرار في المحفظة — وتزداد قيمتها كلما اقتربت من التقاعد.")),
                LibrarySection(
                    title: tr("Sukuk: The Islamic Alternative", "الصكوك: البديل الإسلامي"),
                    body: tr("Sukuk are Sharia-compliant certificates: instead of interest on a loan, holders own a share of a real asset or venture and earn returns from its profits or rentals. The Saudi government and major companies issue sukuk regularly, and funds make them accessible to small investors.",
                             "الصكوك شهادات متوافقة مع الشريعة: بدلاً من فائدة على قرض، يملك حاملوها حصة في أصل أو مشروع حقيقي ويكسبون عوائد من أرباحه أو إيجاراته. تصدر الحكومة السعودية والشركات الكبرى صكوكاً بانتظام، والصناديق تجعلها متاحة لصغار المستثمرين.")),
                LibrarySection(
                    title: tr("The Role of Steady Assets", "دور الأصول المستقرة"),
                    body: tr("Stocks are the engine; bonds and sukuk are the brakes and suspension. A classic mix like 80/20 (stocks/steady assets) when young, shifting steadier with age, smooths the ride enough that you can stay invested through crashes — which is where most real returns are won.",
                             "الأسهم هي المحرك؛ والسندات والصكوك هي المكابح ونظام التعليق. مزيج كلاسيكي مثل 80/20 (أسهم/أصول مستقرة) في الشباب، يتحول تدريجياً نحو الاستقرار مع العمر، يلطف الرحلة بما يكفي لتبقى مستثمراً خلال الانهيارات — وهناك تُكسب معظم العوائد الحقيقية.")),
                LibrarySection(
                    title: tr("Risks Still Exist", "المخاطر لا تزال موجودة"),
                    body: tr("Safer doesn't mean risk-free: issuers can default, and rising rates lower the market value of existing bonds and sukuk. Stick to high-quality issuers (governments, strong companies) and diversified funds rather than single certificates.",
                             "الأكثر أماناً لا يعني بلا مخاطر: قد يتعثر المصدرون، وارتفاع المعدلات يخفض القيمة السوقية للسندات والصكوك القائمة. التزم بمصدرين عاليي الجودة (حكومات وشركات قوية) وصناديق متنوعة بدلاً من شهادات فردية."))
            ]
        ),

        LibrarySubject(
            id: "real-estate",
            title: tr("Real Estate", "العقارات"),
            icon: "building.2",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Property as a home, an income source, and an investment.", "العقار كمسكن ومصدر دخل واستثمار."),
            sections: [
                LibrarySection(
                    title: tr("Why People Love Property", "لماذا يحب الناس العقار"),
                    body: tr("Real estate is tangible, can pay monthly rent, tends to rise with inflation, and can be financed. In Saudi Arabia, programs like Sakani help citizens buy first homes. But property is not automatically a great investment — location, price paid, and costs decide everything.",
                             "العقار ملموس، ويمكن أن يدر إيجاراً شهرياً، ويميل للارتفاع مع التضخم، ويمكن تمويله. في السعودية تساعد برامج مثل «سكني» المواطنين على شراء أول منزل. لكن العقار ليس استثماراً رائعاً تلقائياً — الموقع والسعر المدفوع والتكاليف تحسم كل شيء.")),
                LibrarySection(
                    title: tr("The Costs Nobody Mentions", "التكاليف التي لا يذكرها أحد"),
                    body: tr("Beyond the price: transaction fees, maintenance, insurance, vacancy periods with no tenant, and financing costs. A rental yielding 7% gross often nets 4–5% after expenses. Run honest numbers before believing 'property always wins'.",
                             "بعد السعر: رسوم الصفقة، والصيانة، والتأمين، وفترات الشغور بلا مستأجر، وتكاليف التمويل. عقار يدر 7٪ إجمالاً يصفّي غالباً 4–5٪ بعد المصاريف. احسب بأرقام صادقة قبل تصديق مقولة «العقار يربح دائماً».")),
                LibrarySection(
                    title: tr("REITs: Property Without the Hassle", "صناديق الريت: عقار بلا عناء"),
                    body: tr("Real Estate Investment Trusts (REITs) trade on Tadawul like shares and own portfolios of malls, offices, and warehouses, distributing most rental income as dividends. They offer property exposure with small amounts, instant liquidity, and zero 3am tenant calls.",
                             "صناديق الاستثمار العقاري المتداولة (الريت) تُتداول في تداول كالأسهم وتملك محافظ من المولات والمكاتب والمستودعات، وتوزع معظم دخل الإيجار كأرباح. توفر تعرضاً عقارياً بمبالغ صغيرة وسيولة فورية وصفر مكالمات مستأجرين في الثالثة فجراً.")),
                LibrarySection(
                    title: tr("Home First, Investment Second", "المنزل أولاً والاستثمار ثانياً"),
                    body: tr("Your own home is primarily a place to live — a lifestyle asset with an investment flavor. Buy what you can comfortably afford (payments well under a third of income), in a location that serves your life. Stretching to a 'dream home' that eats every riyal is how house-rich, cash-poor lives are made.",
                             "منزلك في المقام الأول مكان للعيش — أصل نمط حياة بنكهة استثمارية. اشترِ ما يمكنك تحمله براحة (أقساط أقل بكثير من ثلث الدخل) وفي موقع يخدم حياتك. التمدد نحو «منزل الأحلام» الذي يلتهم كل ريال هو وصفة حياة غنية بالجدران فقيرة بالنقد."))
            ]
        ),

        LibrarySubject(
            id: "crypto",
            title: tr("Cryptocurrency", "العملات الرقمية"),
            icon: "bitcoinsign.circle",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Digital assets: the promise, the hype, and the danger.", "الأصول الرقمية: الوعد والضجيج والخطر."),
            sections: [
                LibrarySection(
                    title: tr("What Crypto Is", "ما هي العملات الرقمية"),
                    body: tr("Cryptocurrencies like Bitcoin are digital assets recorded on blockchains — public ledgers no single party controls. No bank stands behind them; their price is purely what the next buyer will pay. That independence is both the appeal and the danger.",
                             "العملات المشفرة مثل بتكوين أصول رقمية مسجلة على سلاسل الكتل (بلوك تشين) — سجلات عامة لا يتحكم بها طرف واحد. لا بنك يقف خلفها؛ وسعرها هو فقط ما سيدفعه المشتري التالي. هذه الاستقلالية هي الجاذبية والخطر معاً.")),
                LibrarySection(
                    title: tr("Extreme Volatility", "تقلبات متطرفة"),
                    body: tr("Crypto can rise or fall 20% in a day and 80% in a year — both have happened repeatedly. Entire exchanges and 'stable' projects have collapsed to zero. Never put money into crypto that you cannot afford to watch vanish completely.",
                             "يمكن للعملات الرقمية أن ترتفع أو تنخفض 20٪ في يوم و80٪ في سنة — وكلاهما حدث مراراً. منصات كاملة ومشاريع «مستقرة» انهارت إلى الصفر. لا تضع أبداً في العملات الرقمية مالاً لا تتحمل رؤيته يتبخر بالكامل.")),
                LibrarySection(
                    title: tr("The Scam Minefield", "حقل ألغام الاحتيال"),
                    body: tr("Crypto's hype attracts fraud: fake exchanges, pump-and-dump groups, 'guaranteed returns' staking schemes, and influencers paid to shill worthless coins. If someone you don't know is eager to help you get rich in crypto, they're getting rich from you.",
                             "ضجيج العملات الرقمية يجذب الاحتيال: منصات مزيفة، ومجموعات نفخ وتفريغ للأسعار، ومخططات إيداع «بعوائد مضمونة»، ومشاهير يتقاضون أجراً للترويج لعملات بلا قيمة. إذا كان شخص لا تعرفه متحمساً لمساعدتك على الثراء بالعملات الرقمية، فهو يثري منك أنت.")),
                LibrarySection(
                    title: tr("If You Still Want In", "إذا كنت لا تزال تريد الدخول"),
                    body: tr("Treat crypto as a small speculative slice — many suggest under 5% of investments — after your foundations are built. Use major established assets and reputable platforms, enable every security feature, and check the regulatory status in the Kingdom, as rules continue to evolve.",
                             "عامل العملات الرقمية كشريحة مضاربة صغيرة — كثيرون يقترحون أقل من 5٪ من الاستثمارات — بعد بناء أساسياتك. استخدم الأصول الكبرى الراسخة والمنصات الموثوقة، وفعّل كل ميزات الأمان، وتحقق من الوضع التنظيمي في المملكة، فالقواعد لا تزال تتطور."))
            ]
        ),

        LibrarySubject(
            id: "retirement",
            title: tr("Retirement Planning", "التخطيط للتقاعد"),
            icon: "sunset",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Building freedom for the decades after work.", "بناء الحرية لعقود ما بعد العمل."),
            sections: [
                LibrarySection(
                    title: tr("Why Think About It Now", "لماذا تفكر فيه الآن"),
                    body: tr("Retirement feels impossibly far at 20 — which is exactly why starting now is so powerful. Money invested at 25 has 40 years to compound; at 7% it multiplies roughly 15 times. Every year you delay costs far more than the amount you skip.",
                             "يبدو التقاعد بعيداً مستحيلاً في العشرين — وهذا بالضبط ما يجعل البدء الآن بهذه القوة. المال المستثمر في الخامسة والعشرين أمامه 40 عاماً ليتراكم؛ عند 7٪ يتضاعف نحو 15 مرة. كل سنة تأخير تكلفك أكثر بكثير من المبلغ الذي تتخطاه.")),
                LibrarySection(
                    title: tr("GOSI: The Foundation", "التأمينات الاجتماعية: الأساس"),
                    body: tr("Saudi employees contribute to GOSI, which provides a pension based on salary and years contributed. It's a vital base — but relying on it alone means accepting a big income drop at retirement. Think of GOSI as the floor, not the ceiling.",
                             "يساهم الموظفون السعوديون في التأمينات الاجتماعية التي توفر معاشاً يعتمد على الراتب وسنوات الاشتراك. إنها قاعدة حيوية — لكن الاعتماد عليها وحدها يعني قبول انخفاض كبير في الدخل عند التقاعد. اعتبر التأمينات الأرضية لا السقف.")),
                LibrarySection(
                    title: tr("Building Your Own Pension", "بناء معاشك الخاص"),
                    body: tr("The gap between GOSI and the life you want must come from your own assets: investment portfolios, property income, business stakes. A common rule of thumb: aim for savings of roughly 25 times your desired annual spending, letting you withdraw ~4% a year indefinitely.",
                             "الفجوة بين التأمينات والحياة التي تريدها يجب أن تأتي من أصولك: محافظ استثمارية، دخل عقاري، حصص أعمال. قاعدة شائعة: استهدف مدخرات تعادل نحو 25 ضعف إنفاقك السنوي المرغوب، لتسحب نحو 4٪ سنوياً إلى ما لا نهاية.")),
                LibrarySection(
                    title: tr("The Simple Long Game", "اللعبة الطويلة البسيطة"),
                    body: tr("The strategy is unglamorous: invest a fixed share of income (15%+ if possible) monthly into diversified low-cost funds, increase it with every raise, and never interrupt it. Decades of this, untouched, quietly builds more wealth than almost any clever scheme.",
                             "الاستراتيجية بلا بريق: استثمر نسبة ثابتة من الدخل (15٪ فأكثر إن أمكن) شهرياً في صناديق متنوعة منخفضة التكلفة، وزدها مع كل علاوة، ولا تقطعها أبداً. عقود من هذا، دون لمسه، تبني بهدوء ثروة تفوق أي مخطط ذكي تقريباً."))
            ]
        ),

        LibrarySubject(
            id: "diversification",
            title: tr("Risk & Diversification", "المخاطر والتنويع"),
            icon: "shield.lefthalf.filled",
            category: tr("Investing", "الاستثمار"),
            summary: tr("Never bet everything on one thing.", "لا تراهن أبداً بكل شيء على شيء واحد."),
            sections: [
                LibrarySection(
                    title: tr("Eggs and Baskets", "البيض والسلال"),
                    body: tr("Diversification means spreading money across many investments so no single failure hurts badly. One stock can go to zero; five hundred stocks across countries and industries essentially cannot. It's the only free lunch in investing: less risk without necessarily less return.",
                             "التنويع يعني توزيع المال عبر استثمارات كثيرة حتى لا يؤلمك فشل واحد بشدة. سهم واحد قد يصل إلى الصفر؛ أما خمسمئة سهم عبر دول وصناعات فعملياً لا يمكن. إنه الوجبة المجانية الوحيدة في الاستثمار: مخاطر أقل دون عائد أقل بالضرورة.")),
                LibrarySection(
                    title: tr("Diversify Across What", "التنويع عبر ماذا"),
                    body: tr("Across companies (many, not one), industries (tech, banks, energy, healthcare), asset types (stocks, sukuk, property, cash), and geographies (Saudi, regional, global). Funds make this trivially easy — one global fund unit touches thousands of businesses.",
                             "عبر الشركات (كثيرة لا واحدة)، والصناعات (تقنية، بنوك، طاقة، رعاية صحية)، وأنواع الأصول (أسهم، صكوك، عقار، نقد)، والجغرافيا (السعودية، الإقليم، العالم). الصناديق تجعل ذلك سهلاً للغاية — وحدة صندوق عالمي واحدة تلامس آلاف الشركات.")),
                LibrarySection(
                    title: tr("Know Your Risk Tolerance", "اعرف تحملك للمخاطر"),
                    body: tr("Can you watch your portfolio drop 30% without selling in panic? Your honest answer sets your stock/steady-asset mix. The best portfolio isn't the one with maximum theoretical return — it's the one you can hold through a crash without abandoning the plan.",
                             "هل تستطيع مشاهدة محفظتك تهبط 30٪ دون بيع بذعر؟ إجابتك الصادقة تحدد مزيجك من الأسهم والأصول المستقرة. أفضل محفظة ليست ذات العائد النظري الأقصى — بل تلك التي تستطيع الاحتفاظ بها خلال انهيار دون التخلي عن الخطة.")),
                LibrarySection(
                    title: tr("Rebalancing", "إعادة التوازن"),
                    body: tr("Once or twice a year, restore your target mix: if stocks grew from 80% to 90% of the portfolio, sell some and top up the steadier side. Rebalancing forces the discipline everyone claims to want — systematically selling high and buying low.",
                             "مرة أو مرتين في السنة أعد مزيجك المستهدف: إذا نمت الأسهم من 80٪ إلى 90٪ من المحفظة، بع بعضها وعزز الجانب الأكثر استقراراً. إعادة التوازن تفرض الانضباط الذي يدعيه الجميع — بيع منهجي عند الارتفاع وشراء عند الانخفاض."))
            ]
        ),

        // ─────────────────────────── Protection & Values ───────────────────────────

        LibrarySubject(
            id: "scams",
            title: tr("Scams & Fraud Protection", "الحماية من الاحتيال"),
            icon: "exclamationmark.shield",
            category: tr("Protection & Values", "الحماية والقيم"),
            summary: tr("Recognizing the tricks before they empty your account.", "التعرف على الحيل قبل أن تفرغ حسابك."),
            sections: [
                LibrarySection(
                    title: tr("The Golden Rules", "القواعد الذهبية"),
                    body: tr("Three rules block most fraud: never share OTP codes with anyone (banks never ask — ever), never click links in unexpected messages, and never trust urgency. 'Your account will be frozen in 30 minutes' is a script designed to stop you thinking. Real institutions don't operate that way.",
                             "ثلاث قواعد تصد معظم الاحتيال: لا تشارك رموز التحقق مع أي أحد أبداً (البنوك لا تطلبها — إطلاقاً)، ولا تضغط روابط في رسائل غير متوقعة، ولا تثق بالاستعجال. «سيُجمد حسابك خلال 30 دقيقة» نص مكتوب ليمنعك من التفكير. المؤسسات الحقيقية لا تعمل هكذا.")),
                LibrarySection(
                    title: tr("Common Scams in the Kingdom", "عمليات الاحتيال الشائعة في المملكة"),
                    body: tr("Fake bank calls asking to 'verify' your details or OTP. Phishing SMS about undelivered packages or unpaid fines with poisoned links. Fake online stores with prices too good to be true. 'Investment platforms' on social media promising guaranteed monthly returns. Job offers demanding upfront fees.",
                             "مكالمات بنكية مزيفة تطلب «التحقق» من بياناتك أو رمز التحقق. رسائل تصيد عن طرود لم تُسلّم أو مخالفات غير مدفوعة بروابط مسمومة. متاجر إلكترونية وهمية بأسعار أجمل من أن تكون حقيقية. «منصات استثمار» على وسائل التواصل تعد بعوائد شهرية مضمونة. وعروض عمل تطالب برسوم مقدمة.")),
                LibrarySection(
                    title: tr("Spotting the Pattern", "اكتشاف النمط"),
                    body: tr("Every scam shares DNA: an unexpected contact, a story creating urgency or greed, and a request — codes, transfers, gift cards, remote access. When any two appear together, assume fraud. Hang up, don't reply, and contact the organization through its official app or number yourself.",
                             "كل احتيال يتشارك الجينات نفسها: تواصل غير متوقع، وقصة تصنع استعجالاً أو طمعاً، وطلب — رموز، تحويلات، بطاقات هدايا، وصول عن بعد. عندما يجتمع اثنان منها افترض الاحتيال. أغلق الخط، ولا ترد، وتواصل مع الجهة عبر تطبيقها أو رقمها الرسمي بنفسك.")),
                LibrarySection(
                    title: tr("If You've Been Scammed", "إذا وقعت ضحية احتيال"),
                    body: tr("Act fast: call your bank immediately to freeze cards and dispute transfers, change your passwords, and report via official channels (banks' fraud lines and the authorities' reporting apps). Speed matters more than embarrassment — and reporting protects the next victim too.",
                             "تصرف بسرعة: اتصل ببنكك فوراً لتجميد البطاقات والاعتراض على التحويلات، وغيّر كلمات مرورك، وأبلغ عبر القنوات الرسمية (خطوط مكافحة الاحتيال في البنوك وتطبيقات الجهات الأمنية). السرعة أهم من الإحراج — والإبلاغ يحمي الضحية التالية أيضاً."))
            ]
        ),

        LibrarySubject(
            id: "insurance",
            title: tr("Insurance", "التأمين"),
            icon: "umbrella",
            category: tr("Protection & Values", "الحماية والقيم"),
            summary: tr("Paying a little to avoid losing everything.", "تدفع القليل لتتجنب خسارة كل شيء."),
            sections: [
                LibrarySection(
                    title: tr("How Insurance Works", "كيف يعمل التأمين"),
                    body: tr("Many people pay small premiums into a pool; the unlucky few who suffer losses are paid from it. You're not buying a product — you're buying protection from disasters too big for your savings. The best outcome is paying and never needing it.",
                             "يدفع كثيرون أقساطاً صغيرة في وعاء مشترك؛ ويُعوض منه القلة سيئو الحظ الذين تصيبهم خسائر. أنت لا تشتري منتجاً — بل حماية من كوارث أكبر من مدخراتك. أفضل نتيجة هي أن تدفع ولا تحتاجه أبداً.")),
                LibrarySection(
                    title: tr("Insurance You'll Meet", "أنواع التأمين التي ستقابلها"),
                    body: tr("Health insurance (employer-provided for most Saudi workers), mandatory car insurance (third-party at minimum — comprehensive covers your own car too), travel insurance, and home contents cover. Takaful versions structure the pool along Islamic cooperative principles.",
                             "التأمين الصحي (يوفره صاحب العمل لمعظم العاملين في السعودية)، وتأمين السيارات الإلزامي (ضد الغير كحد أدنى — والشامل يغطي سيارتك أيضاً)، وتأمين السفر، وتغطية محتويات المنزل. ونسخ التكافل تنظم الوعاء وفق مبادئ التعاون الإسلامية.")),
                LibrarySection(
                    title: tr("Choosing Sensibly", "الاختيار بحكمة"),
                    body: tr("Insure against catastrophes, not inconveniences: events that would wreck you financially. Compare coverage limits and exclusions, not just price — the cheapest policy that doesn't pay out is the most expensive thing you'll ever buy. Read what's excluded before signing.",
                             "أمّن ضد الكوارث لا الإزعاجات: الأحداث التي ستدمرك مالياً. قارن حدود التغطية والاستثناءات لا السعر فقط — أرخص وثيقة لا تدفع عند الحاجة هي أغلى شيء ستشتريه في حياتك. اقرأ المستثنيات قبل التوقيع.")),
                LibrarySection(
                    title: tr("Don't Over-Insure", "لا تفرط في التأمين"),
                    body: tr("Extended warranties on cheap electronics, flight insurance for refundable tickets, gadget cover costing 30% of the item's price — usually poor value. If you can comfortably replace something from savings, self-insure by keeping that emergency fund strong.",
                             "الضمانات الممتدة للإلكترونيات الرخيصة، وتأمين الرحلات للتذاكر القابلة للاسترداد، وتغطية جهاز تكلف 30٪ من سعره — قيمتها ضعيفة عادة. إذا كنت تستطيع استبدال شيء براحة من مدخراتك، أمّن على نفسك ذاتياً بإبقاء صندوق الطوارئ قوياً."))
            ]
        ),

        LibrarySubject(
            id: "islamic-finance",
            title: tr("Islamic Finance", "التمويل الإسلامي"),
            icon: "moon.stars",
            category: tr("Protection & Values", "الحماية والقيم"),
            summary: tr("Managing money in line with Sharia principles.", "إدارة المال وفق أحكام الشريعة."),
            sections: [
                LibrarySection(
                    title: tr("Core Principles", "المبادئ الأساسية"),
                    body: tr("Islamic finance rests on a few pillars: no riba (interest on money itself), no gharar (excessive uncertainty or gambling), no financing of prohibited industries, and the sharing of profit and risk. Money should grow through real trade and assets, not by renting money.",
                             "يقوم التمويل الإسلامي على ركائز قليلة: لا ربا (فائدة على المال ذاته)، ولا غرر (غموض مفرط أو مقامرة)، ولا تمويل لقطاعات محرمة، ومشاركة في الربح والمخاطرة. ينبغي أن ينمو المال عبر تجارة وأصول حقيقية، لا عبر تأجير المال.")),
                LibrarySection(
                    title: tr("Everyday Islamic Banking", "الخدمات المصرفية الإسلامية اليومية"),
                    body: tr("Islamic banks offer familiar services through compliant structures: Murabaha (cost-plus sale) for car and home financing, Ijara (leasing), Mudaraba (profit-sharing investment accounts), and Musharaka (partnerships). Most Saudi banks operate fully or partially under these models.",
                             "تقدم البنوك الإسلامية خدمات مألوفة عبر هياكل متوافقة: المرابحة (بيع بالتكلفة زائد ربح) لتمويل السيارات والمنازل، والإجارة (التأجير)، والمضاربة (حسابات استثمار بمشاركة الأرباح)، والمشاركة (الشراكات). معظم البنوك السعودية تعمل كلياً أو جزئياً بهذه النماذج.")),
                LibrarySection(
                    title: tr("Halal Investing", "الاستثمار الحلال"),
                    body: tr("Sharia-compliant investing screens out prohibited sectors and companies with excessive debt or interest income. Tadawul flags compliant stocks, and many funds and ETFs — local and global — apply these screens automatically, often purifying incidental income through charity.",
                             "الاستثمار المتوافق مع الشريعة يستبعد القطاعات المحرمة والشركات ذات الديون أو الدخل الربوي المفرط. تداول تحدد الأسهم المتوافقة، وكثير من الصناديق — المحلية والعالمية — تطبق هذه الفلاتر تلقائياً، وغالباً تطهّر الدخل العرضي بالتبرع به.")),
                LibrarySection(
                    title: tr("Values and Wealth Together", "القيم والثروة معاً"),
                    body: tr("Islamic finance frames wealth as a trust (amanah): earn honestly, avoid exploitation, pay Zakat, and spend with responsibility. Whatever your starting point, the discipline of asking 'is this earning real and fair?' tends to produce not just compliant portfolios, but sturdier ones.",
                             "يرى التمويل الإسلامي المال أمانة: اكسب بصدق، وتجنب الاستغلال، وأدِّ الزكاة، وأنفق بمسؤولية. أياً كانت نقطة انطلاقك، فإن انضباط السؤال «هل هذا الكسب حقيقي وعادل؟» يميل لإنتاج محافظ ليست متوافقة فحسب، بل أكثر متانة."))
            ]
        ),

        LibrarySubject(
            id: "financial-goals",
            title: tr("Setting Financial Goals", "تحديد الأهداف المالية"),
            icon: "target",
            category: tr("Protection & Values", "الحماية والقيم"),
            summary: tr("Turning vague wishes into funded plans.", "تحويل الأماني الغامضة إلى خطط ممولة."),
            sections: [
                LibrarySection(
                    title: tr("Why Goals Beat Wishes", "لماذا تتفوق الأهداف على الأماني"),
                    body: tr("'I want to be rich someday' funds nothing. 'I need 30,000 SAR for a car down payment by June 2028' tells you exactly what to save monthly. Specific goals with numbers and dates convert dreams into simple math — and math is achievable.",
                             "«أريد أن أكون غنياً يوماً ما» لا يموّل شيئاً. «أحتاج 30,000 ريال دفعة أولى لسيارة بحلول يونيو 2028» يخبرك بالضبط كم تدخر شهرياً. الأهداف المحددة بأرقام وتواريخ تحول الأحلام إلى حساب بسيط — والحساب قابل للتحقيق.")),
                LibrarySection(
                    title: tr("Make Them SMART", "اجعلها ذكية (SMART)"),
                    body: tr("Good goals are Specific, Measurable, Achievable, Relevant, and Time-bound. Break big ones into milestones: a 120,000 SAR wedding fund in four years is 2,500 SAR a month — suddenly it's a budgeting line, not a fantasy.",
                             "الأهداف الجيدة محددة وقابلة للقياس وقابلة للتحقيق وذات صلة ومحددة زمنياً. قسّم الكبيرة إلى محطات: صندوق زواج بـ120,000 ريال خلال أربع سنوات يعني 2,500 ريال شهرياً — فجأة يصبح بنداً في الميزانية لا خيالاً.")),
                LibrarySection(
                    title: tr("Match Money to Timeline", "طابق المال مع الإطار الزمني"),
                    body: tr("Goals under 2–3 years away belong in safe savings — the money must exist when needed. Goals 5+ years out can ride in investments and grow. Mixing these up (investing next year's tuition, or keeping retirement money in cash for decades) is a classic costly error.",
                             "الأهداف الأقرب من 2–3 سنوات مكانها الادخار الآمن — يجب أن يوجد المال عند الحاجة. أما أهداف 5 سنوات فأكثر فيمكنها الركوب في الاستثمارات والنمو. الخلط بينهما (استثمار رسوم دراسة العام القادم، أو إبقاء مال التقاعد نقداً لعقود) خطأ كلاسيكي مكلف.")),
                LibrarySection(
                    title: tr("Review and Celebrate", "راجع واحتفل"),
                    body: tr("Life changes — salaries rise, plans shift, surprises land. Review goals every few months, adjust the numbers, and actually celebrate milestones (cheaply!). Progress you notice is progress you continue; goals nobody looks at quietly die.",
                             "الحياة تتغير — الرواتب ترتفع، والخطط تتبدل، والمفاجآت تهبط. راجع أهدافك كل بضعة أشهر، وعدّل الأرقام، واحتفل فعلاً بالمحطات (بتكلفة زهيدة!). التقدم الذي تلاحظه تقدم تواصله؛ والأهداف التي لا ينظر إليها أحد تموت بصمت."))
            ]
        )
        ]
    }
}
