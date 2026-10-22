// Pocock D2D: pannello nascosto (niente Dock né barra menu), presente su tutte le scrivanie,
// che si mostra e si nasconde con una scorciatoia globale sulla P.
import Carbon.HIToolbox
import Cocoa
import WebKit

let bundleID = "local.pocock-d2d"
let toggleNote = Notification.Name("local.pocock-d2d.toggle")
let dataDir = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Application Support/PocockD2D")

// In ordine di preferenza: si usa la prima combinazione che nessun'altra app ha già registrato.
let candidates: [(mods: Int, label: String)] = [
    (controlKey | optionKey, "⌃⌥P"),
    (controlKey | optionKey | cmdKey, "⌃⌥⌘P"),
    (controlKey | optionKey | shiftKey, "⌃⌥⇧P"),
    (controlKey | shiftKey | cmdKey, "⌃⇧⌘P"),
]

final class Panel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    override func cancelOperation(_ sender: Any?) { orderOut(nil) }  // Esc nasconde
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKUIDelegate {
    var panel: Panel!
    var hotKey: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        buildPanel()
        registerHotKey()
        DistributedNotificationCenter.default().addObserver(
            self, selector: #selector(toggle), name: toggleNote, object: nil)
    }

    // Doppio clic sull'app (o `open`) mentre è già in esecuzione: mostra il pannello.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        show()
        return false
    }

    func buildPanel() {
        let frame = NSRect(x: 0, y: 0, width: 1000, height: 820)
        panel = Panel(contentRect: frame, styleMask: [.titled, .closable, .resizable],
                      backing: .buffered, defer: false)
        panel.title = "Pocock D2D"
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        if !panel.setFrameUsingName("PocockD2DPanel") { panel.center() }
        panel.setFrameAutosaveName("PocockD2DPanel")

        let web = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        web.autoresizingMask = [.width, .height]
        web.uiDelegate = self
        panel.contentView = web
        let page = Bundle.main.resourceURL!.appendingPathComponent("www/index.html")
        web.loadFileURL(page, allowingReadAccessTo: page.deletingLastPathComponent())
    }

    // I link target="_blank" (fonti GitHub) si aprono nel browser predefinito.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { NSWorkspace.shared.open(url) }
        return nil
    }

    // Menu mai visibile (app senza barra menu), serve solo per ⌘C/⌘V/⌘A/⌘W nel pannello.
    func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Nascondi", action: #selector(hidePanel), keyEquivalent: "w")
        appItem.submenu = appMenu
        main.addItem(appItem)
        let editItem = NSMenuItem()
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Copia", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Seleziona tutto", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        edit.addItem(withTitle: "Incolla", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editItem.submenu = edit
        main.addItem(editItem)
        NSApp.mainMenu = main
    }

    func registerHotKey() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            let me = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
            DispatchQueue.main.async { me.toggle() }
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), nil)

        let id = EventHotKeyID(signature: OSType(0x5043_4B44), id: 1)  // 'PCKD'
        var chosen = "nessuna (tutte le combinazioni con la P sono già in uso)"
        for c in candidates {
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(UInt32(kVK_ANSI_P), UInt32(c.mods), id,
                                             GetApplicationEventTarget(), OptionBits(kEventHotKeyExclusive), &ref)
            if status == noErr {
                hotKey = ref
                chosen = c.label
                break
            }
        }
        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        try? chosen.write(to: dataDir.appendingPathComponent("shortcut.txt"), atomically: true, encoding: .utf8)
    }

    @objc func toggle() {
        if panel.isVisible && panel.isKeyWindow { hidePanel() } else { show() }
    }

    @objc func hidePanel() { panel.orderOut(nil) }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }
}

// Una sola istanza: se è già attiva, le chiede di mostrarsi ed esce.
let others = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
    .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
if !others.isEmpty {
    DistributedNotificationCenter.default().postNotificationName(
        toggleNote, object: nil, userInfo: nil, deliverImmediately: true)
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
