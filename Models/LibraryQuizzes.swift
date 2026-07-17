import Foundation

// MARK: - Quiz Model

struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctIndex: Int
}

/// Three knowledge-check questions per library subject. Passing the quiz is
/// what marks a subject as completed (and feeds the Scholar badge) — reading
/// alone is not enough.
enum LibraryQuizzes {

    static func questions(for subjectID: String) -> [QuizQuestion] {
        switch subjectID {

        case "what-is-money": return [
            QuizQuestion(
                text: tr("Why was money invented?", "لماذا اختُرع المال؟"),
                options: [
                    tr("Because gold was discovered", "لأن الذهب اكتُشف"),
                    tr("Because barter only worked when both people wanted exactly what the other had", "لأن المقايضة لا تنجح إلا إذا أراد كل طرف ما يملكه الآخر بالضبط"),
                    tr("Because banks needed something to store", "لأن البنوك احتاجت شيئاً لتخزينه")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Which of these is NOT one of money's three jobs?", "أي مما يلي ليس من وظائف المال الثلاث؟"),
                options: [
                    tr("Medium of exchange", "وسيلة للتبادل"),
                    tr("Store of value", "مخزن للقيمة"),
                    tr("Growing crops", "زراعة المحاصيل")
                ],
                correctIndex: 2),
            QuizQuestion(
                text: tr("Why does a 100-riyal note have value?", "لماذا لورقة المئة ريال قيمة؟"),
                options: [
                    tr("The paper itself is expensive", "الورق نفسه غالي الثمن"),
                    tr("Everyone agrees it does, and the government guarantees it settles debts", "لأن الجميع متفقون على قيمتها والحكومة تضمن أنها تسدد الديون"),
                    tr("Each note is backed by a barrel of oil", "كل ورقة مدعومة ببرميل نفط")
                ],
                correctIndex: 1)
        ]

        case "budgeting": return [
            QuizQuestion(
                text: tr("In the 50/30/20 rule, where does the 20% go?", "في قاعدة 50/30/20، إلى أين تذهب الـ20٪؟"),
                options: [
                    tr("Wants", "الرغبات"),
                    tr("Needs", "الاحتياجات"),
                    tr("Savings or paying off debt", "الادخار أو سداد الديون")
                ],
                correctIndex: 2),
            QuizQuestion(
                text: tr("What's the best question before an impulse buy?", "ما أفضل سؤال قبل شراء اندفاعي؟"),
                options: [
                    tr("Will my friends like it?", "هل سيعجب أصدقائي؟"),
                    tr("If I wait a week, will I still want this?", "إذا انتظرت أسبوعاً، هل سأظل أريده؟"),
                    tr("Can I pay for it in installments?", "هل يمكنني تقسيطه؟")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("A budget works best when you…", "تنجح الميزانية عندما…"),
                options: [
                    tr("Set it once and forget it", "تضعها مرة وتنساها"),
                    tr("Track what you actually spend, then adjust", "تتابع ما تنفقه فعلاً ثم تعدّل"),
                    tr("Only plan for big purchases", "تخطط للمشتريات الكبيرة فقط")
                ],
                correctIndex: 1)
        ]

        case "saving": return [
            QuizQuestion(
                text: tr("What does 'pay yourself first' mean?", "ماذا تعني قاعدة «ادفع لنفسك أولاً»؟"),
                options: [
                    tr("Move money to savings the moment income arrives", "حوّل المال إلى الادخار فور وصول الدخل"),
                    tr("Buy what you want before paying bills", "اشترِ ما تريد قبل دفع الفواتير"),
                    tr("Save whatever is left at month's end", "ادخر ما يتبقى آخر الشهر")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("The most reliable way to make saving stick is…", "أكثر طريقة موثوقة لتثبيت عادة الادخار هي…"),
                options: [
                    tr("Strong willpower", "قوة الإرادة"),
                    tr("An automatic transfer every payday", "تحويل تلقائي في كل يوم راتب"),
                    tr("Saving only after a good month", "الادخار بعد شهر جيد فقط")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Who usually ends up richer?", "من ينتهي به الأمر أغنى عادة؟"),
                options: [
                    tr("Saving 500 SAR/month from age 20", "من يدخر 500 ريال شهرياً منذ سن العشرين"),
                    tr("Saving 1,500 SAR/month from age 40", "من يدخر 1,500 ريال شهرياً منذ الأربعين"),
                    tr("Both end up the same", "كلاهما ينتهي بالنتيجة نفسها")
                ],
                correctIndex: 0)
        ]

        case "emergency-fund": return [
            QuizQuestion(
                text: tr("The classic emergency fund target is…", "الهدف التقليدي لصندوق الطوارئ هو…"),
                options: [
                    tr("One week of expenses", "مصاريف أسبوع واحد"),
                    tr("3–6 months of essential expenses", "3–6 أشهر من المصاريف الأساسية"),
                    tr("Ten years of salary", "راتب عشر سنوات")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Where should emergency money live?", "أين يجب أن يبقى مال الطوارئ؟"),
                options: [
                    tr("In stocks", "في الأسهم"),
                    tr("In crypto", "في العملات الرقمية"),
                    tr("In a separate instant-access savings account", "في حساب ادخار منفصل يمكن الوصول إليه فوراً")
                ],
                correctIndex: 2),
            QuizQuestion(
                text: tr("Which of these counts as an emergency?", "أي مما يلي يُعد حالة طارئة؟"),
                options: [
                    tr("A sale on sneakers", "تخفيضات على الأحذية"),
                    tr("A hospital visit", "زيارة مستشفى"),
                    tr("A new phone launch", "إطلاق هاتف جديد")
                ],
                correctIndex: 1)
        ]

        case "banking": return [
            QuizQuestion(
                text: tr("Banks mainly make money by…", "تربح البنوك أساساً من…"),
                options: [
                    tr("Lending deposits at higher rates, plus fees", "إقراض الودائع بمعدلات أعلى، إضافة إلى الرسوم"),
                    tr("Printing new money", "طباعة نقود جديدة"),
                    tr("Government salaries", "رواتب حكومية")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("The difference between debit and credit cards is…", "الفرق بين بطاقة الخصم والبطاقة الائتمانية هو…"),
                options: [
                    tr("There is no difference", "لا فرق بينهما"),
                    tr("Debit spends your own money now; credit borrows the bank's money", "الخصم تنفق أموالك فوراً؛ والائتمانية تقترض أموال البنك"),
                    tr("Credit cards spend your savings account", "الائتمانية تنفق من حساب توفيرك")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Your bank calls asking for your OTP code. You should…", "اتصل بك «البنك» يطلب رمز التحقق. عليك أن…"),
                options: [
                    tr("Give it if it sounds urgent", "تعطيه إذا بدا الأمر عاجلاً"),
                    tr("Never give it — real banks never ask", "لا تعطيه أبداً — البنوك الحقيقية لا تطلبه"),
                    tr("Give only half the digits", "تعطي نصف الأرقام فقط")
                ],
                correctIndex: 1)
        ]

        case "interest": return [
            QuizQuestion(
                text: tr("By the Rule of 72, money at 6% a year doubles in about…", "وفق قاعدة الـ72، المال بعائد 6٪ سنوياً يتضاعف خلال نحو…"),
                options: [
                    tr("6 years", "6 سنوات"),
                    tr("12 years", "12 سنة"),
                    tr("72 years", "72 سنة")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Compounding means…", "التراكم يعني…"),
                options: [
                    tr("Earning returns on your returns", "كسب عوائد على عوائدك"),
                    tr("A fixed fee every year", "رسماً ثابتاً كل سنة"),
                    tr("Interest that never changes", "فائدة لا تتغير أبداً")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Compounding works AGAINST you when…", "يعمل التراكم ضدك عندما…"),
                options: [
                    tr("You save early", "تدخر مبكراً"),
                    tr("You pay only the minimum on expensive debt", "تدفع الحد الأدنى فقط على دين مكلف"),
                    tr("You invest monthly", "تستثمر شهرياً")
                ],
                correctIndex: 1)
        ]

        case "inflation": return [
            QuizQuestion(
                text: tr("If inflation is 3%, something that cost 100 SAR last year now costs about…", "إذا كان التضخم 3٪، فما كان يكلف 100 ريال العام الماضي يكلف الآن نحو…"),
                options: [
                    tr("97 SAR", "97 ريالاً"),
                    tr("103 SAR", "103 ريالات"),
                    tr("100 SAR exactly", "100 ريال بالضبط")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Cash hidden under a mattress for ten years…", "النقود المخبأة تحت الفراش عشر سنوات…"),
                options: [
                    tr("Keeps its exact buying power", "تحافظ على قوتها الشرائية تماماً"),
                    tr("Quietly buys less and less", "تشتري أقل فأقل بصمت"),
                    tr("Grows on its own", "تنمو من تلقاء نفسها")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Beating inflation long-term usually means…", "التفوق على التضخم طويلاً يعني عادة…"),
                options: [
                    tr("Keeping everything in cash", "إبقاء كل شيء نقداً"),
                    tr("Investing in assets that historically outgrow it, like diversified funds", "الاستثمار في أصول تتفوق عليه تاريخياً مثل الصناديق المتنوعة"),
                    tr("Spending money faster", "إنفاق المال بشكل أسرع")
                ],
                correctIndex: 1)
        ]

        case "income": return [
            QuizQuestion(
                text: tr("You should build your budget around…", "يجب أن تبني ميزانيتك على…"),
                options: [
                    tr("Your gross salary", "راتبك الإجمالي"),
                    tr("Your net salary after deductions", "راتبك الصافي بعد الاستقطاعات"),
                    tr("Your yearly bonus", "مكافأتك السنوية")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("A job's real value includes…", "القيمة الحقيقية للوظيفة تشمل…"),
                options: [
                    tr("The salary number only", "رقم الراتب فقط"),
                    tr("Salary plus allowances, insurance, training, and end-of-service benefits", "الراتب مع البدلات والتأمين والتدريب ومكافأة نهاية الخدمة"),
                    tr("The size of the office", "حجم المكتب")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("The best investment most young people can make is…", "أفضل استثمار يمكن لمعظم الشباب القيام به هو…"),
                options: [
                    tr("Their own skills", "مهاراتهم وقدراتهم"),
                    tr("Luxury watches", "الساعات الفاخرة"),
                    tr("Lottery tickets", "أوراق اليانصيب")
                ],
                correctIndex: 0)
        ]

        case "entrepreneurship": return [
            QuizQuestion(
                text: tr("Before spending big on a business idea, you should…", "قبل الإنفاق الكبير على فكرة مشروع، عليك أن…"),
                options: [
                    tr("Rent a fancy office", "تستأجر مكتباً فاخراً"),
                    tr("Sell a simple version first and prove real demand", "تبيع نسخة بسيطة أولاً وتثبت وجود طلب حقيقي"),
                    tr("Print business cards", "تطبع بطاقات أعمال")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Business money should be…", "أموال المشروع يجب أن تكون…"),
                options: [
                    tr("Mixed with personal money", "مخلوطة بالمال الشخصي"),
                    tr("Separate from personal money from day one", "منفصلة عن المال الشخصي من اليوم الأول"),
                    tr("Kept as cash at home", "محفوظة نقداً في المنزل")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Registering officially (freelance permit, Maroof)…", "التسجيل الرسمي (وثيقة العمل الحر، معروف)…"),
                options: [
                    tr("Wastes time", "مضيعة للوقت"),
                    tr("Protects you and builds customer trust", "يحميك ويبني ثقة العملاء"),
                    tr("Is only for big companies", "للشركات الكبيرة فقط")
                ],
                correctIndex: 1)
        ]

        case "taxes-zakat": return [
            QuizQuestion(
                text: tr("VAT in Saudi Arabia is currently…", "ضريبة القيمة المضافة في السعودية حالياً…"),
                options: ["5%", "15%", "25%"],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Zakat on wealth above the nisab is…", "زكاة المال فوق النصاب هي…"),
                options: ["2.5%", "10%", "50%"],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Money you owe (Zakat, VAT you collected) should be…", "المال المستحق عليك (زكاة أو ضريبة حصّلتها) يجب أن…"),
                options: [
                    tr("Treated as never yours and set aside as it accrues", "يعامل كأنه ليس لك ويُعزل أولاً بأول"),
                    tr("Spent now and figured out later", "يُنفق الآن ويُدبَّر لاحقاً"),
                    tr("Ignored until someone asks", "يُتجاهل حتى يسأل أحد")
                ],
                correctIndex: 0)
        ]

        case "credit": return [
            QuizQuestion(
                text: tr("What does SIMAH record?", "ماذا تسجل «سمة»؟"),
                options: [
                    tr("Your borrowing and repayment history", "تاريخ اقتراضك وسدادك"),
                    tr("Your salary only", "راتبك فقط"),
                    tr("Your shopping preferences", "تفضيلاتك في التسوق")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Paying only the card's minimum payment…", "دفع الحد الأدنى فقط لبطاقتك…"),
                options: [
                    tr("Clears the debt quickly", "يسدد الدين بسرعة"),
                    tr("Lets the rest keep growing with fees", "يترك الباقي ينمو مع الرسوم"),
                    tr("Improves your record fastest", "يحسّن سجلك بأسرع طريقة")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Good credit history is built by…", "يُبنى السجل الائتماني الجيد عبر…"),
                options: [
                    tr("Paying on time and keeping balances low", "السداد في الموعد وإبقاء الأرصدة منخفضة"),
                    tr("Applying for many products at once", "التقديم على منتجات كثيرة دفعة واحدة"),
                    tr("Ignoring small bills", "تجاهل الفواتير الصغيرة")
                ],
                correctIndex: 0)
        ]

        case "loans": return [
            QuizQuestion(
                text: tr("\u{201C}Good debt\u{201D} pays for…", "«الدين الجيد» يشتري…"),
                options: [
                    tr("Vacations", "الإجازات"),
                    tr("Appreciating assets or earning power, like a home or education", "أصولاً تنمو قيمتها أو قدرة على الكسب، كمنزل أو تعليم"),
                    tr("The newest gadgets", "أحدث الأجهزة")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Compare loans by…", "قارن القروض حسب…"),
                options: [
                    tr("Monthly installment only", "القسط الشهري فقط"),
                    tr("APR and total repayment", "معدل النسبة السنوي وإجمالي السداد"),
                    tr("The bank's advertisements", "إعلانات البنك")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("A common safe limit: total debt payments under…", "قاعدة أمان شائعة: أقساط الديون الإجمالية أقل من…"),
                options: [
                    tr("A third of your net income", "ثلث دخلك الصافي"),
                    tr("90% of your income", "90٪ من دخلك"),
                    tr("Whatever the bank approves", "أي مبلغ يوافق عليه البنك")
                ],
                correctIndex: 0)
        ]

        case "debt-management": return [
            QuizQuestion(
                text: tr("The first step out of debt is…", "الخطوة الأولى للخروج من الديون هي…"),
                options: [
                    tr("Hiding from the bank's calls", "الاختباء من اتصالات البنك"),
                    tr("Listing every debt with its balance, rate, and minimum", "كتابة كل دين برصيده ومعدله وحده الأدنى"),
                    tr("Opening a new credit card", "فتح بطاقة ائتمانية جديدة")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("The avalanche method attacks…", "طريقة «الانهيار» تهاجم…"),
                options: [
                    tr("The highest-rate debt first", "الدين ذا المعدل الأعلى أولاً"),
                    tr("The smallest balance first", "أصغر رصيد أولاً"),
                    tr("A random debt each month", "ديناً عشوائياً كل شهر")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("If you can't cover the minimums, you should…", "إذا عجزت عن تغطية الحدود الدنيا، عليك أن…"),
                options: [
                    tr("Contact your bank early to restructure", "تتواصل مع بنكك مبكراً لإعادة الجدولة"),
                    tr("Ignore it and hope", "تتجاهل الأمر وتأمل"),
                    tr("Use buy-now-pay-later to cover them", "تغطيها بخدمة اشترِ الآن وادفع لاحقاً")
                ],
                correctIndex: 0)
        ]

        case "investing-basics": return [
            QuizQuestion(
                text: tr("Higher potential returns always come with…", "العوائد المحتملة الأعلى تأتي دائماً مع…"),
                options: [
                    tr("Lower risk", "مخاطر أقل"),
                    tr("Higher risk", "مخاطر أعلى"),
                    tr("No risk at all", "بلا مخاطر إطلاقاً")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("What beats clever market timing for almost everyone?", "ما الذي يتفوق على التوقيت الذكي للسوق لدى الجميع تقريباً؟"),
                options: [
                    tr("Jumping in and out at the right moments", "الدخول والخروج في اللحظات المناسبة"),
                    tr("Investing a fixed amount monthly, regardless of headlines", "استثمار مبلغ ثابت شهرياً بغض النظر عن الأخبار"),
                    tr("Following one hot stock", "ملاحقة سهم رائج واحد")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Before investing, you should first have…", "قبل الاستثمار يجب أن يكون لديك أولاً…"),
                options: [
                    tr("An emergency fund and expensive debt paid off", "صندوق طوارئ وديون مكلفة مسددة"),
                    tr("A loan to invest bigger", "قرض لتستثمر بمبلغ أكبر"),
                    tr("A tip from social media", "نصيحة من وسائل التواصل")
                ],
                correctIndex: 0)
        ]

        case "stocks": return [
            QuizQuestion(
                text: tr("A share is…", "السهم هو…"),
                options: [
                    tr("A loan you give a company", "قرض تمنحه لشركة"),
                    tr("A small ownership slice of a real company", "حصة ملكية صغيرة في شركة حقيقية"),
                    tr("A discount coupon", "قسيمة تخفيض")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Daily share price moves are mostly…", "تحركات أسعار الأسهم اليومية في معظمها…"),
                options: [
                    tr("Noise", "ضجيج"),
                    tr("Exact company performance", "أداء الشركة بدقة"),
                    tr("Dividends", "أرباح موزعة")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("The Saudi stock exchange is called…", "تسمى السوق المالية السعودية…"),
                options: [
                    tr("Tadawul", "تداول"),
                    tr("NASDAQ", "ناسداك"),
                    tr("SIMAH", "سمة")
                ],
                correctIndex: 0)
        ]

        case "funds": return [
            QuizQuestion(
                text: tr("A fund's biggest advantage is…", "أكبر ميزة للصندوق هي…"),
                options: [
                    tr("Instant diversification across many assets", "تنويع فوري عبر أصول كثيرة"),
                    tr("Guaranteed returns", "عوائد مضمونة"),
                    tr("Zero fees always", "رسوم صفرية دائماً")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Index funds…", "صناديق المؤشرات…"),
                options: [
                    tr("Copy a market index at very low cost", "تنسخ مؤشر سوق بتكلفة منخفضة جداً"),
                    tr("Hire managers to guess winning stocks", "توظف مديرين لتخمين الأسهم الرابحة"),
                    tr("Are only for professionals", "للمحترفين فقط")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("A 2% annual fee over 30 years can…", "رسم سنوي 2٪ خلال 30 عاماً يمكن أن…"),
                options: [
                    tr("Be safely ignored", "يُتجاهل بأمان"),
                    tr("Consume about a third of your final wealth", "يلتهم نحو ثلث ثروتك النهائية"),
                    tr("Improve your returns", "يحسّن عوائدك")
                ],
                correctIndex: 1)
        ]

        case "sukuk-bonds": return [
            QuizQuestion(
                text: tr("A bond is…", "السند هو…"),
                options: [
                    tr("Ownership in a company", "ملكية في شركة"),
                    tr("A loan you give to a government or company", "قرض تمنحه لحكومة أو شركة"),
                    tr("A type of savings account", "نوع من حسابات التوفير")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Sukuk holders earn returns from…", "يكسب حاملو الصكوك عوائدهم من…"),
                options: [
                    tr("Interest on lent money", "فائدة على مال مُقرض"),
                    tr("A share of a real asset's profits or rentals", "حصة من أرباح أو إيجارات أصل حقيقي"),
                    tr("Lottery draws", "سحوبات الحظ")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("In a portfolio, bonds and sukuk act as…", "في المحفظة، تعمل السندات والصكوك بمثابة…"),
                options: [
                    tr("The engine", "المحرك"),
                    tr("The stabilizer", "عامل الاستقرار"),
                    tr("Decoration", "زينة")
                ],
                correctIndex: 1)
        ]

        case "real-estate": return [
            QuizQuestion(
                text: tr("A rental yielding 7% gross often nets, after real costs…", "عقار يدر 7٪ إجمالاً يصفّي غالباً بعد التكاليف الحقيقية…"),
                options: ["7%", tr("4–5%", "4–5٪"), "12%"],
                correctIndex: 1),
            QuizQuestion(
                text: tr("REITs let you…", "صناديق الريت تتيح لك…"),
                options: [
                    tr("Own property exposure with small amounts and instant liquidity", "تعرضاً عقارياً بمبالغ صغيرة وسيولة فورية"),
                    tr("Avoid all investment risk", "تجنب كل مخاطر الاستثمار"),
                    tr("Get a free apartment", "الحصول على شقة مجانية")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("The home you buy should…", "المنزل الذي تشتريه يجب أن…"),
                options: [
                    tr("Eat every riyal you have — it's worth it", "يلتهم كل ريال تملكه — يستحق ذلك"),
                    tr("Be comfortably affordable, with payments well under a third of income", "يكون في حدود قدرتك براحة، بأقساط أقل بكثير من ثلث الدخل"),
                    tr("Be the biggest one the bank approves", "يكون أكبر ما يوافق عليه البنك")
                ],
                correctIndex: 1)
        ]

        case "crypto": return [
            QuizQuestion(
                text: tr("A cryptocurrency's price is backed by…", "سعر العملة الرقمية مدعوم بـ…"),
                options: [
                    tr("A central bank", "بنك مركزي"),
                    tr("Only what the next buyer will pay", "فقط ما سيدفعه المشتري التالي"),
                    tr("Gold reserves", "احتياطيات ذهب")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("A sensible crypto allocation is often suggested as…", "التخصيص المعقول للعملات الرقمية يُقترح غالباً بأنه…"),
                options: [
                    tr("Under 5% of investments, after foundations are built", "أقل من 5٪ من الاستثمارات، بعد بناء الأساسيات"),
                    tr("Everything you own", "كل ما تملك"),
                    tr("Half your monthly salary", "نصف راتبك الشهري")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("A stranger online eager to make you rich in crypto is…", "شخص غريب على الإنترنت متحمس لإثرائك بالعملات الرقمية هو…"),
                options: [
                    tr("A generous friend", "صديق كريم"),
                    tr("Getting rich from you", "يثري منك أنت"),
                    tr("Probably licensed", "مرخص على الأرجح")
                ],
                correctIndex: 1)
        ]

        case "retirement": return [
            QuizQuestion(
                text: tr("Money invested at 25, at 7% a year, multiplies over 40 years roughly…", "المال المستثمر في الخامسة والعشرين بعائد 7٪ سنوياً يتضاعف خلال 40 عاماً نحو…"),
                options: [tr("2×", "مرتين"), tr("15×", "15 مرة"), tr("100×", "100 مرة")],
                correctIndex: 1),
            QuizQuestion(
                text: tr("GOSI should be treated as…", "يجب اعتبار التأمينات الاجتماعية…"),
                options: [
                    tr("The ceiling of your retirement", "سقف تقاعدك"),
                    tr("The floor — a base you build on", "الأرضية — قاعدة تبني فوقها"),
                    tr("Optional and unimportant", "أمراً اختيارياً غير مهم")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("A common retirement rule of thumb: savings of about…", "قاعدة تقاعد شائعة: مدخرات تعادل نحو…"),
                options: [
                    tr("25× your desired annual spending", "25 ضعف إنفاقك السنوي المرغوب"),
                    tr("2× your salary", "ضعف راتبك"),
                    tr("One year of rent", "إيجار سنة واحدة")
                ],
                correctIndex: 0)
        ]

        case "diversification": return [
            QuizQuestion(
                text: tr("Diversification means…", "التنويع يعني…"),
                options: [
                    tr("Betting everything on one winner", "المراهنة بكل شيء على رابح واحد"),
                    tr("Spreading money so no single failure hurts badly", "توزيع المال حتى لا يؤلمك فشل واحد بشدة"),
                    tr("Avoiding stocks completely", "تجنب الأسهم تماماً")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Your stock/steady-asset mix should be set by…", "مزيجك من الأسهم والأصول المستقرة يجب أن يحدده…"),
                options: [
                    tr("Maximum theoretical return", "العائد النظري الأقصى"),
                    tr("What you can hold through a crash without panic-selling", "ما تستطيع الاحتفاظ به خلال انهيار دون بيع بذعر"),
                    tr("A friend's tip", "نصيحة صديق")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Rebalancing means…", "إعادة التوازن تعني…"),
                options: [
                    tr("Restoring your target mix — systematically selling high and buying low", "استعادة مزيجك المستهدف — بيع منهجي عند الارتفاع وشراء عند الانخفاض"),
                    tr("Selling everything in a crash", "بيع كل شيء عند الانهيار"),
                    tr("Buying more of whatever grew most", "شراء المزيد مما نما أكثر")
                ],
                correctIndex: 0)
        ]

        case "scams": return [
            QuizQuestion(
                text: tr("When do banks ask for your OTP code?", "متى تطلب البنوك رمز التحقق منك؟"),
                options: [
                    tr("Only in urgent cases", "في الحالات العاجلة فقط"),
                    tr("Never", "أبداً"),
                    tr("Once a month", "مرة في الشهر")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("Every scam shares the same DNA:", "كل عملية احتيال تتشارك النمط نفسه:"),
                options: [
                    tr("Unexpected contact + urgency or greed + a request", "تواصل غير متوقع + استعجال أو طمع + طلب"),
                    tr("Bad grammar only", "أخطاء لغوية فقط"),
                    tr("Foreign phone numbers only", "أرقام أجنبية فقط")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("If you've been scammed, the FIRST thing to do is…", "إذا وقعت ضحية احتيال، أول ما تفعله هو…"),
                options: [
                    tr("Hide it out of embarrassment", "إخفاء الأمر بسبب الإحراج"),
                    tr("Call your bank immediately to freeze cards and dispute transfers", "الاتصال ببنكك فوراً لتجميد البطاقات والاعتراض على التحويلات"),
                    tr("Post about it on social media", "النشر عنه في وسائل التواصل")
                ],
                correctIndex: 1)
        ]

        case "insurance": return [
            QuizQuestion(
                text: tr("Insurance makes the most sense for…", "التأمين منطقي أكثر ما يكون لـ…"),
                options: [
                    tr("Catastrophes too big for your savings", "الكوارث الأكبر من مدخراتك"),
                    tr("Small inconveniences", "الإزعاجات الصغيرة"),
                    tr("Guaranteed profit", "ربح مضمون")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("The cheapest policy that doesn't pay out when needed is…", "أرخص وثيقة لا تدفع عند الحاجة هي…"),
                options: [
                    tr("A great bargain", "صفقة رائعة"),
                    tr("The most expensive thing you'll ever buy", "أغلى شيء ستشتريه في حياتك"),
                    tr("The industry standard", "المعيار المعتاد")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("An extended warranty on cheap electronics is usually…", "الضمان الممتد للإلكترونيات الرخيصة عادة…"),
                options: [
                    tr("Great value", "قيمة ممتازة"),
                    tr("Poor value — self-insure with your emergency fund", "قيمة ضعيفة — أمّن ذاتياً عبر صندوق الطوارئ"),
                    tr("Legally required", "إلزامي قانوناً")
                ],
                correctIndex: 1)
        ]

        case "islamic-finance": return [
            QuizQuestion(
                text: tr("Riba means…", "الربا يعني…"),
                options: [
                    tr("Interest on money itself", "فائدة على المال ذاته"),
                    tr("Profit from honest trade", "ربحاً من تجارة نزيهة"),
                    tr("Rent from property", "إيجاراً من عقار")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Murabaha financing is…", "تمويل المرابحة هو…"),
                options: [
                    tr("The bank buys the item and sells it to you at a marked-up price in installments", "يشتري البنك السلعة ويبيعها لك بسعر أعلى يُدفع أقساطاً"),
                    tr("An interest-bearing loan", "قرض بفائدة"),
                    tr("A prize draw", "سحب على جوائز")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Islamic finance says money should grow through…", "يرى التمويل الإسلامي أن المال ينمو عبر…"),
                options: [
                    tr("Renting money out", "تأجير المال"),
                    tr("Real trade and assets, with shared profit and risk", "تجارة وأصول حقيقية بمشاركة الربح والمخاطرة"),
                    tr("Speculation and chance", "المضاربة والحظ")
                ],
                correctIndex: 1)
        ]

        case "financial-goals": return [
            QuizQuestion(
                text: tr("Which of these is a real financial goal?", "أي مما يلي هدف مالي حقيقي؟"),
                options: [
                    tr("\u{201C}I want to be rich someday\u{201D}", "«أريد أن أكون غنياً يوماً ما»"),
                    tr("\u{201C}30,000 SAR for a car down payment by June 2028\u{201D}", "«30,000 ريال دفعة أولى لسيارة بحلول يونيو 2028»"),
                    tr("\u{201C}Save more\u{201D}", "«أن أدخر أكثر»")
                ],
                correctIndex: 1),
            QuizQuestion(
                text: tr("SMART goals are…", "الأهداف الذكية (SMART) هي…"),
                options: [
                    tr("Specific, Measurable, Achievable, Relevant, Time-bound", "محددة وقابلة للقياس وقابلة للتحقيق وذات صلة ومحددة زمنياً"),
                    tr("Secret, Massive, Ambitious, Risky, Trendy", "سرية وضخمة وطموحة وخطرة ورائجة"),
                    tr("Anything written down", "أي شيء مكتوب")
                ],
                correctIndex: 0),
            QuizQuestion(
                text: tr("Money for goals under 2–3 years away belongs in…", "مال الأهداف الأقرب من 2–3 سنوات مكانه…"),
                options: [
                    tr("Investments", "الاستثمارات"),
                    tr("Safe savings", "الادخار الآمن"),
                    tr("Crypto", "العملات الرقمية")
                ],
                correctIndex: 1)
        ]

        default: return []
        }
    }
}
