// Profil fotoğrafı ve öne çıkan hikâye kapakları: profil/
import AppKit
let a = CommandLine.arguments
Kit.setup(root: a[1], fonts: a[2], icon: a[3])
let out = a[1] + "/profil"
// Profil fotoğrafı: uygulama ikonu (Instagram daire kırpar; ikonun ortası güvenli).
let p = Surface(1080, 1080)
p.drawFill(Kit.cgImage(a[4])!, in: CGRect(x: 0, y: 0, width: 1080, height: 1080))
p.saveJPEG(out + "/profil-fotografi.jpg")
// Öne çıkan kapakları: ortadaki daire görünür.
let covers: [(String, String, NSColor)] = [("1-nasil", "questionmark", Kit.gold), ("2-once-sonra", "rectangle.split.2x1.fill", Kit.mint),
    ("3-widget", "lock.iphone", Kit.blue), ("4-kareyo30", "flame.fill", Kit.coral), ("5-yenilikler", "sparkles", Kit.gold)]
for (name, symbol, color) in covers {
    let s = Surface(1080, 1920)
    s.background([(0.5, 0.5, 0.9, color.withAlphaComponent(0.25))], grain: false)
    let r = CGRect(x: 240, y: 660, width: 600, height: 600)
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [color.cgColor, color.blended(withFraction: 0.45, of: Kit.hex(0x0A0F1E))!.cgColor] as CFArray, locations: [0, 1])!
    s.ctx.saveGState(); s.ctx.addEllipse(in: r); s.ctx.clip()
    s.ctx.drawLinearGradient(g, start: CGPoint(x: r.minX, y: r.minY), end: CGPoint(x: r.maxX, y: r.maxY), options: []); s.ctx.restoreGState()
    let cfg = NSImage.SymbolConfiguration(pointSize: 230, weight: .semibold).applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?.withSymbolConfiguration(cfg) {
        let sz = img.size
        img.draw(in: NSRect(x: r.midX - sz.width / 2, y: r.midY - sz.height / 2, width: sz.width, height: sz.height), from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
    }
    s.saveJPEG("\(out)/one-cikan-\(name).jpg")
}
print("ok")
