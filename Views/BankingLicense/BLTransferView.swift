import SwiftUI

struct BLTransferView: View {
    @State private var selectedTransferType = 0
    @State private var beneficiaryName = ""
    @State private var iban = ""
    @State private var amount = ""
    @State private var saveToBeneficiary = true
    @State private var showFeatureAlert = false

    private let transferTypes = [
        ("creditcard", tr("Transfer via card number", "تحويل عبر رقم البطاقة")),
        ("person.2", tr("Transfer to the same bank", "تحويل داخل نفس البنك")),
        ("building.2", tr("Transfer to another bank", "تحويل إلى بنك آخر"))
    ]

    private let beneficiaries = [
        ("plus", tr("Add", "إضافة")),
        ("person.fill", "Hassan"),
        ("person.fill", "Hamad"),
        ("person.fill", "Amar")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Card Selector
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("VISA **** **** **** 9018")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )

                    Text(tr("Available balance : 24,345.92 SAR", "الرصيد المتاح: 24,345.92 ريال"))
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                // Choose Transaction
                VStack(alignment: .leading, spacing: 12) {
                    Text(tr("Choose transaction", "اختر نوع العملية"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 10) {
                        ForEach(0..<transferTypes.count, id: \.self) { index in
                            let type = transferTypes[index]
                            Button {
                                selectedTransferType = index
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: type.0)
                                        .font(.title3)
                                    Text(type.1)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .foregroundColor(selectedTransferType == index ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTransferType == index ? Color.bankPurple : Color(.systemGray6))
                                )
                            }
                        }
                    }
                }

                // Choose Beneficiary
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(tr("Choose beneficiary", "اختر المستفيد"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(tr("Find beneficiary", "البحث عن مستفيد")) { }
                            .font(.subheadline)
                            .foregroundColor(.bankPurple)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<beneficiaries.count, id: \.self) { index in
                                let b = beneficiaries[index]
                                VStack(spacing: 6) {
                                    Image(systemName: b.0)
                                        .font(.title2)
                                        .foregroundColor(index == 0 ? .bankPurple : .gray)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle()
                                                .fill(Color(.systemGray5))
                                        )
                                    Text(b.1)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }

                // Transfer Form
                VStack(spacing: 14) {
                    transferField(tr("Name of Beneficiary", "اسم المستفيد"), text: $beneficiaryName)
                    transferField(tr("IBan", "الآيبان"), text: $iban)
                    transferField(tr("Amount of Money you want to transfer", "المبلغ الذي تريد تحويله"), text: $amount)
                        .keyboardType(.decimalPad)

                    Toggle(isOn: $saveToBeneficiary) {
                        Text(tr("Save to directory of beneficiary", "حفظ في دليل المستفيدين"))
                            .font(.subheadline)
                    }
                    .tint(.bankPurple)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                )

                // Confirm Button
                Button {
                    showFeatureAlert = true
                } label: {
                    Text(tr("Confirm", "تأكيد"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.bankPurple)
                        )
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(tr("Transfer", "تحويل"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(tr("Check Back Later!", "عد لاحقاً!"), isPresented: $showFeatureAlert) {
            Button(tr("Okay!", "حسناً!"), role: .cancel) { }
        } message: {
            Text(tr("This Feature isn't ready yet, please come back later.", "هذه الميزة ليست جاهزة بعد، يرجى العودة لاحقاً."))
        }
    }

    private func transferField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }
}
