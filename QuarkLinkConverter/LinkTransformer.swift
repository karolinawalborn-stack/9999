import Foundation

struct LinkTransformResult {
    let text: String
    let count: Int
}

enum LinkTransformError: LocalizedError {
    case emptyInput
    case noQuarkLinks
    case invalidDomain

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "请先粘贴文案或夸克链接"
        case .noQuarkLinks:
            return "没有找到 pan.quark.cn 的分享链接"
        case .invalidDomain:
            return "自定义域名格式不正确"
        }
    }
}

struct LinkTransformer {
    private static let urlPattern = #"https?://(?:www\.)?(?:pan\.)?(?:quark\.cn|quarket\.xyz)/s/[A-Za-z0-9_-]{4,128}(?:\?[^\s<>\]\[)\}，。；;！!？?]*)?"#
    private static let supportedHosts = ["pan.quark.cn", "quark.cn", "pan.quarket.xyz"]

    func transform(_ input: String, targetDomain: String) throws -> LinkTransformResult {
        let trimmedDomain = targetDomain
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .lowercased()

        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LinkTransformError.emptyInput
        }
        guard isValidDomain(trimmedDomain) else {
            throw LinkTransformError.invalidDomain
        }

        let regex = try NSRegularExpression(pattern: Self.urlPattern, options: [.caseInsensitive])
        let nsInput = input as NSString
        let fullRange = NSRange(location: 0, length: nsInput.length)
        let matches = regex.matches(in: input, options: [], range: fullRange)
        guard !matches.isEmpty else { throw LinkTransformError.noQuarkLinks }

        let output = NSMutableString(string: input)
        for match in matches.reversed() {
            let original = nsInput.substring(with: match.range)
            guard let converted = convert(original, targetDomain: trimmedDomain) else { continue }
            output.replaceCharacters(in: match.range, with: converted)
        }

        return LinkTransformResult(text: output as String, count: matches.count)
    }

    private func convert(_ rawURL: String, targetDomain: String) -> String? {
        guard var components = URLComponents(string: rawURL),
              let host = components.host?.lowercased(),
              Self.supportedHosts.contains(host),
              components.path.range(of: #"^/s/[A-Za-z0-9_-]{4,128}/?$"#, options: .regularExpression) != nil else {
            return nil
        }
        components.scheme = "https"
        components.host = targetDomain
        return components.string
    }

    private func isValidDomain(_ domain: String) -> Bool {
        guard !domain.isEmpty, domain.count <= 253 else { return false }
        return domain.range(of: #"^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$"#, options: .regularExpression) != nil
    }
}
