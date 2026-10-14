import SwiftUI
import UIKit

struct ContentView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var targetDomain = "pan.xiaozyi.xyz"
    @State private var status = ""
    @State private var statusIsError = false
    @State private var isCopied = false

    private let transformer = LinkTransformer()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    domainField
                    editor(title: "原始文案", text: $input, placeholder: "粘贴包含夸克链接的文案，例如：\n\n资源名称\nhttps://pan.quark.cn/s/54dd63db3625\n\n更多说明")
                    actionRow
                    statusView
                    if !output.isEmpty {
                        editor(title: "转换结果（文案保持不变）", text: .constant(output), placeholder: "转换结果")
                        Button(action: copyOutput) {
                            Label(isCopied ? "已复制" : "复制完整文案", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    tips
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("夸克链接转换")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清空") { clearAll() }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "arrow.up.right.square.fill")
                .font(.system(size: 34))
                .foregroundStyle(.blue)
            Text("文案和链接一起粘贴")
                .font(.title2.bold())
            Text("自动识别一个或多个夸克分享链接，只替换链接域名，其他文字原样保留。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var domainField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("你的转换域名").font(.headline)
            TextField("例如 pan.xiaozyi.xyz", text: $targetDomain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
        }
    }

    private func editor(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                TextEditor(text: text)
                    .frame(minHeight: 145)
                    .padding(7)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.18)))
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: transform) {
                Label("开始转换", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button(action: pasteFromClipboard) {
                Label("粘贴", systemImage: "doc.on.clipboard")
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder private var statusView: some View {
        if !status.isEmpty {
            Label(status, systemImage: statusIsError ? "exclamationmark.triangle" : "checkmark.circle")
                .font(.subheadline)
                .foregroundStyle(statusIsError ? .red : .green)
        }
    }

    private var tips: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("支持内容").font(.headline)
            Text("• 文案中包含多个夸克链接时会一次全部转换\n• ?pwd=提取码等参数会完整保留\n• 转换和复制都在本机完成，不上传文案")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private func transform() {
        do {
            let result = try transformer.transform(input, targetDomain: targetDomain)
            output = result.text
            statusIsError = false
            status = "已转换 \(result.count) 个链接"
            isCopied = false
        } catch {
            output = ""
            statusIsError = true
            status = error.localizedDescription
        }
    }

    private func pasteFromClipboard() {
        if let value = UIPasteboard.general.string {
            input = value
            status = "已粘贴剪贴板内容"
            statusIsError = false
        }
    }

    private func copyOutput() {
        guard !output.isEmpty else { return }
        UIPasteboard.general.string = output
        isCopied = true
        status = "完整文案已复制"
        statusIsError = false
    }

    private func clearAll() {
        input = ""
        output = ""
        status = ""
        isCopied = false
    }
}

#Preview {
    ContentView()
}
