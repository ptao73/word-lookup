// 查词 —— 在任何 App 里选中英文单词,右键 → 服务 → 查词,弹出释义 + 英/美发音
// 释义来源:macOS 自带的《牛津英汉汉英词典》(Simplified Chinese - English,离线)
// 发音来源:有道词典公开发音接口(type=1 英音,type=2 美音)
import AppKit
import AVFoundation
import CoreServices

// macOS 私有函数:按文件路径打开一本指定的词典(系统"词典"App 也在用)
@_silgen_name("DCSDictionaryCreate")
func DCSDictionaryCreate(_ url: CFURL) -> Unmanaged<AnyObject>?

// ---------- 查词典 ----------
enum Dict {
    // 找到系统里那本英汉词典(系统更新后路径里的编号可能变,所以每次搜索)
    static let dictionary: DCSDictionary? = {
        let base = "/System/Library/AssetsV2/com_apple_MobileAsset_DictionaryServices_dictionary3macOS"
        let fm = FileManager.default
        for sub in (try? fm.contentsOfDirectory(atPath: base)) ?? [] {
            let p = "\(base)/\(sub)/AssetData/Simplified Chinese - English.dictionary"
            if fm.fileExists(atPath: p), let d = DCSDictionaryCreate(URL(fileURLWithPath: p) as CFURL) {
                return unsafeBitCast(d.takeRetainedValue(), to: DCSDictionary.self)
            }
        }
        return nil
    }()

    // 返回释义纯文本;找不到返回 nil
    static func lookup(_ word: String) -> String? {
        guard let d = dictionary else { return "(找不到系统英汉词典,请在「词典」App 设置里勾选 简体中文-英文)" }
        let r = CFRange(location: 0, length: (word as NSString).length)
        return DCSCopyTextDefinition(d, word as CFString, r)?.takeRetainedValue() as String?
    }

    // 把一整行释义拆成好读的多行:①② 义项换行,▸ 例句缩进
    static func pretty(_ s: String) -> String {
        var t = s
        for n in ["①","②","③","④","⑤","⑥","⑦","⑧","⑨","⑩"] { t = t.replacingOccurrences(of: n, with: "\n\(n)") }
        t = t.replacingOccurrences(of: "▸", with: "\n    ▸")
        // "A. intransitive verb" 这种大段落前空一行
        t = t.replacingOccurrences(of: " ([A-H])\\. ", with: "\n\n$1. ", options: .regularExpression)
        return t
    }
}

// ---------- 弹出窗口 ----------
final class LookupPanel: NSObject {
    static let shared = LookupPanel()
    private var panel: NSPanel!
    private var textView: NSTextView!
    private var player: AVPlayer?
    private var word = ""

    private func build() {
        panel = EscPanel(contentRect: NSRect(x: 0, y: 0, width: 440, height: 340),
                        styleMask: [.titled, .closable, .resizable, .utilityWindow],
                        backing: .buffered, defer: false)
        panel.level = .floating                 // 浮在其他窗口上面
        panel.hidesOnDeactivate = false

        // 释义文字区(可滚动、可选中复制)
        let scroll = NSTextView.scrollableTextView()
        textView = (scroll.documentView as! NSTextView)
        textView.isEditable = false
        textView.textContainerInset = NSSize(width: 8, height: 8)

        // 底部按钮
        func btn(_ title: String, _ sel: Selector) -> NSButton {
            let b = NSButton(title: title, target: self, action: sel); b.bezelStyle = .rounded; return b
        }
        let uk = btn("🔊 英", #selector(playUK)); uk.keyEquivalent = "1"; uk.keyEquivalentModifierMask = []
        let us = btn("🔊 美", #selector(playUS)); us.keyEquivalent = "2"; us.keyEquivalentModifierMask = []
        let gs = btn("在高山词根中打开", #selector(openGhosun))
        let row = NSStackView(views: [uk, us, NSView(), gs])
        row.orientation = .horizontal

        let col = NSStackView(views: [scroll, row])
        col.orientation = .vertical
        col.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        row.edgeInsets = NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        panel.contentView = col
    }

    func show(_ raw: String) {
        if panel == nil { build() }
        // 只保留字母、连字符、撇号和空格,去掉首尾标点
        word = raw.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        if word.isEmpty { return }
        panel.title = word

        let body = Dict.lookup(word).map(Dict.pretty) ?? "词典里没有找到「\(word)」。\n可以点下面的发音按钮,或在高山词根中打开。"
        let text = NSMutableAttributedString(string: body, attributes: [
            .font: NSFont.systemFont(ofSize: 14), .foregroundColor: NSColor.labelColor])
        // 第一段(词头 | 音标)加粗
        if let bar = body.range(of: "|", options: .backwards, range: body.startIndex..<(body.firstIndex(of: "\n") ?? body.endIndex)) {
            text.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: 16), range: NSRange(body.startIndex..<bar.upperBound, in: body))
        }
        textView.textStorage?.setAttributedString(text)
        textView.scrollToBeginningOfDocument(nil)

        // 窗口出现在鼠标附近
        let m = NSEvent.mouseLocation
        panel.setFrameTopLeftPoint(NSPoint(x: m.x + 12, y: m.y - 12))
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    // 有道发音:type=1 英音,type=2 美音
    private func play(_ type: Int) {
        var c = URLComponents(string: "https://dict.youdao.com/dictvoice")!
        c.queryItems = [URLQueryItem(name: "audio", value: word), URLQueryItem(name: "type", value: "\(type)")]
        player = AVPlayer(url: c.url!)
        player?.play()
    }
    @objc func playUK() { play(1) }
    @objc func playUS() { play(2) }

    // 用高山词根自己的链接打开这个词
    @objc func openGhosun() {
        let w = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? word
        if let u = URL(string: "ghosundict://\(w)") { NSWorkspace.shared.open(u) }
    }

}

// 按 Esc 关闭窗口
final class EscPanel: NSPanel {
    override func cancelOperation(_ sender: Any?) { close() }
}

// ---------- 系统"服务"菜单入口 ----------
final class ServiceProvider: NSObject {
    // 名字 lookup 要和 Info.plist 里的 NSMessage 一致
    @objc func lookup(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let s = pboard.string(forType: .string) else { return }
        DispatchQueue.main.async { LookupPanel.shared.show(s) }
    }
}

// ---------- 程序入口 ----------
final class AppDelegate: NSObject, NSApplicationDelegate {
    let provider = ServiceProvider()
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.servicesProvider = provider
        NSUpdateDynamicServices()
        // 方便测试:命令行 `open -a 查词 --args carbon` 也能直接查
        let args = CommandLine.arguments.dropFirst().filter { !$0.hasPrefix("-") }
        if let w = args.first { LookupPanel.shared.show(w) }
    }
    // 也支持链接 chaci://单词 (以后给键盘快捷键/浏览器用)
    func application(_ app: NSApplication, open urls: [URL]) {
        if let u = urls.first, let w = (u.host ?? u.path).removingPercentEncoding { LookupPanel.shared.show(w) }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)   // 不在 Dock 显示图标
app.run()
