// Ortak çizim kiti: Kutup Işığı arka planı, Sora yazı tipi, telefon çerçevesi, kart, çip, marka.
// Görsel (images.swift) ve video (video.swift) üreticileri bunu kullanır.
import AppKit
import CoreText
import ImageIO

enum Kit {
    static var root = ""          // marketing/social
    static var sources: String { root + "/content/sources" }

    static func setup(root: String, fonts: String, icon: String) {
        self.root = root
        for f in ["Sora-Regular", "Sora-SemiBold", "Sora-Bold", "Sora-ExtraBold"] {
            CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: "\(fonts)/\(f).ttf") as CFURL, .process, nil)
        }
        iconPath = icon
    }
    static var iconPath = ""
    static var iconImage: CGImage { cgImage(iconPath)! }

    static func font(_ w: String, _ s: CGFloat) -> NSFont { NSFont(name: "Sora-\(w)", size: s) ?? .systemFont(ofSize: s, weight: .bold) }
    static func hex(_ h: UInt32, _ a: CGFloat = 1) -> NSColor { NSColor(srgbRed: CGFloat((h >> 16) & 255)/255, green: CGFloat((h >> 8) & 255)/255, blue: CGFloat(h & 255)/255, alpha: a) }
    static let ink = hex(0xF3F5FB), muted = hex(0xA9B3CC), gold = hex(0xFFC978), mint = hex(0x6FE3B4), coral = hex(0xFF8A6B), blue = hex(0x7C93FF)
    static func accent(_ name: String?) -> NSColor { ["mint": mint, "coral": coral, "blue": blue][name ?? ""] ?? gold }

    private static var cache: [String: CGImage] = [:]
    /// "pilea/day30", "screens/home", "launch/01-lansman-4x5" gibi kısa yollar ya da tam yol.
    static func cgImage(_ ref: String) -> CGImage? {
        if let c = cache[ref] { return c }
        var path = ref
        if !ref.hasPrefix("/") {
            path = ["jpg", "png"].map { "\(sources)/\(ref).\($0)" }.first { FileManager.default.fileExists(atPath: $0) } ?? ""
        }
        guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
              let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
        cache[ref] = img
        return img
    }
    static func seq(_ name: String, _ day: Int) -> CGImage? { cgImage("\(name)/day\(String(format: "%02d", day))") }
}

/// Üstten-aşağı koordinatlı çizim yüzeyi.
final class Surface {
    let w: CGFloat, h: CGFloat, ctx: CGContext
    init(_ w: CGFloat, _ h: CGFloat, context: CGContext? = nil) {
        self.w = w; self.h = h
        ctx = context ?? CGContext(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.translateBy(x: 0, y: h); ctx.scaleBy(x: 1, y: -1)
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)
    }
    func activate() { NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true) }

    func saveJPEG(_ path: String) {
        let img = ctx.makeImage()!
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, "public.jpeg" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
        CGImageDestinationFinalize(dest)
    }

    func background(_ glows: [(CGFloat, CGFloat, CGFloat, NSColor)], grain: Bool = true) {
        ctx.setFillColor(Kit.hex(0x0A0F1E).cgColor); ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        for (x, y, r, c) in glows {
            let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c.cgColor, c.withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1])!
            ctx.drawRadialGradient(g, startCenter: CGPoint(x: x * w, y: y * h), startRadius: 0, endCenter: CGPoint(x: x * w, y: y * h), endRadius: r * w, options: [])
        }
        guard grain else { return }
        var s: UInt64 = 42
        for _ in 0..<Int(w * h / 140) {
            s = s &* 6364136223846793005 &+ 1442695040888963407
            ctx.setFillColor(((s & 1) == 0 ? NSColor.white : NSColor.black).withAlphaComponent(0.035).cgColor)
            ctx.fill(CGRect(x: CGFloat((s >> 20) % UInt64(w)), y: CGFloat((s >> 40) % UInt64(h)), width: 2, height: 2))
        }
    }
    func glowsFor(_ accent: NSColor, _ variant: Int = 0) -> [(CGFloat, CGFloat, CGFloat, NSColor)] {
        let others = [Kit.blue, Kit.mint, Kit.coral, Kit.gold].filter { $0 != accent }
        let a = others[variant % others.count], b = others[(variant + 1) % others.count]
        return [(variant % 2 == 0 ? 0.15 : 0.85, 0.05, 0.8, accent.withAlphaComponent(0.32)), (variant % 2 == 0 ? 0.95 : 0.05, 0.6, 0.7, a.withAlphaComponent(0.22)), (0.4, 1.05, 0.7, b.withAlphaComponent(0.16))]
    }

    @discardableResult
    func text(_ s: String, _ f: NSFont, _ c: NSColor, x: CGFloat, y: CGFloat, width: CGFloat, kern: CGFloat = 0, line: CGFloat = 1.12, align: NSTextAlignment = .left, alpha: CGFloat = 1) -> CGFloat {
        let p = NSMutableParagraphStyle(); p.lineHeightMultiple = line; p.alignment = align
        let a = NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: c.withAlphaComponent(c.alphaComponent * alpha), .kern: kern, .paragraphStyle: p])
        let r = a.boundingRect(with: NSSize(width: width, height: 4000), options: [.usesLineFragmentOrigin, .usesFontLeading])
        a.draw(with: NSRect(x: x, y: y, width: width, height: ceil(r.height)), options: [.usesLineFragmentOrigin, .usesFontLeading])
        return ceil(r.height)
    }
    func textHeight(_ s: String, _ f: NSFont, width: CGFloat, kern: CGFloat = 0, line: CGFloat = 1.12) -> CGFloat {
        let p = NSMutableParagraphStyle(); p.lineHeightMultiple = line
        return ceil(NSAttributedString(string: s, attributes: [.font: f, .kern: kern, .paragraphStyle: p]).boundingRect(with: NSSize(width: width, height: 4000), options: [.usesLineFragmentOrigin, .usesFontLeading]).height)
    }

    /// Görüntüyü dikdörtgene "aspect fill" çizer (ters çevrilmiş bağlamda doğru yönde).
    func drawFill(_ img: CGImage, in r: CGRect, focusY: CGFloat = 0.5, zoom: CGFloat = 1, alpha: CGFloat = 1) {
        let iw = CGFloat(img.width), ih = CGFloat(img.height)
        let s = max(r.width / iw, r.height / ih) * zoom
        let dw = iw * s, dh = ih * s
        let dr = CGRect(x: r.midX - dw / 2, y: r.minY - (dh - r.height) * focusY, width: dw, height: dh)
        ctx.saveGState(); ctx.clip(to: r); ctx.setAlpha(alpha)
        ctx.translateBy(x: dr.minX, y: dr.maxY); ctx.scaleBy(x: 1, y: -1)
        ctx.draw(img, in: CGRect(x: 0, y: 0, width: dw, height: dh))
        ctx.restoreGState()
    }
    func rotated(_ deg: CGFloat, around p: CGPoint, _ body: () -> Void) {
        ctx.saveGState(); ctx.translateBy(x: p.x, y: p.y); ctx.rotate(by: deg * .pi / 180); ctx.translateBy(x: -p.x, y: -p.y); body(); ctx.restoreGState()
    }
    func rounded(_ r: CGRect, _ radius: CGFloat) -> CGPath { CGPath(roundedRect: r, cornerWidth: min(radius, r.width / 2), cornerHeight: min(radius, r.height / 2), transform: nil) }

    func phone(_ img: CGImage, _ r: CGRect, angle: CGFloat = 0, alpha: CGFloat = 1) {
        rotated(angle, around: CGPoint(x: r.midX, y: r.midY)) {
            ctx.setAlpha(alpha)
            let radius = r.width * 0.135
            ctx.saveGState(); ctx.setShadow(offset: CGSize(width: 0, height: 30), blur: 70, color: NSColor.black.withAlphaComponent(0.6).cgColor)
            ctx.addPath(rounded(r, radius)); ctx.setFillColor(Kit.hex(0x101218).cgColor); ctx.fillPath(); ctx.restoreGState()
            let inset = r.width * 0.028, screen = r.insetBy(dx: inset, dy: inset)
            ctx.saveGState(); ctx.addPath(rounded(screen, radius - inset)); ctx.clip(); drawFill(img, in: screen, focusY: 0); ctx.restoreGState()
            ctx.addPath(rounded(r.insetBy(dx: 1, dy: 1), radius)); ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.22).cgColor); ctx.setLineWidth(2); ctx.strokePath()
            ctx.setAlpha(1)
        }
    }
    func card(_ img: CGImage, _ r: CGRect, angle: CGFloat = 0, radius: CGFloat = 36, focusY: CGFloat = 0.5, zoom: CGFloat = 1, alpha: CGFloat = 1) {
        rotated(angle, around: CGPoint(x: r.midX, y: r.midY)) {
            ctx.setAlpha(alpha)
            ctx.saveGState(); ctx.setShadow(offset: CGSize(width: 0, height: 24), blur: 60, color: NSColor.black.withAlphaComponent(0.55).cgColor)
            ctx.addPath(rounded(r, radius)); ctx.setFillColor(NSColor.black.cgColor); ctx.fillPath(); ctx.restoreGState()
            ctx.saveGState(); ctx.addPath(rounded(r, radius)); ctx.clip(); drawFill(img, in: r, focusY: focusY, zoom: zoom); ctx.restoreGState()
            ctx.addPath(rounded(r.insetBy(dx: 1, dy: 1), radius)); ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor); ctx.setLineWidth(2); ctx.strokePath()
            ctx.setAlpha(1)
        }
    }
    func glass(_ r: CGRect, radius: CGFloat, alpha: CGFloat = 0.1) {
        ctx.addPath(rounded(r, radius)); ctx.setFillColor(NSColor.white.withAlphaComponent(alpha).cgColor); ctx.fillPath()
        ctx.addPath(rounded(r.insetBy(dx: 0.75, dy: 0.75), radius)); ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.2).cgColor); ctx.setLineWidth(1.5); ctx.strokePath()
    }
    @discardableResult
    func chip(_ s: String, x: CGFloat, y: CGFloat, color: NSColor = Kit.ink, size: CGFloat = 24, dark: Bool = false, alignRight: Bool = false) -> CGFloat {
        let f = Kit.font("SemiBold", size)
        let tw = (s as NSString).size(withAttributes: [.font: f]).width
        let width = tw + size * 1.4
        let r = CGRect(x: alignRight ? x - width : x, y: y, width: width, height: size * 2.1)
        if dark { ctx.addPath(rounded(r, r.height / 2)); ctx.setFillColor(NSColor.black.withAlphaComponent(0.6).cgColor); ctx.fillPath() }
        else { glass(r, radius: r.height / 2, alpha: 0.12) }
        text(s, f, color, x: r.minX + size * 0.7, y: y + size * 0.48, width: tw + 10)
        return width
    }
    func brand(x: CGFloat, y: CGFloat, size: CGFloat = 54, alpha: CGFloat = 1) {
        ctx.saveGState(); ctx.setAlpha(alpha)
        ctx.addPath(rounded(CGRect(x: x, y: y, width: size, height: size), size * 0.23)); ctx.clip()
        drawFill(Kit.iconImage, in: CGRect(x: x, y: y, width: size, height: size))
        ctx.restoreGState()
        text("Kareyo", Kit.font("Bold", size * 0.56), Kit.ink, x: x + size + 16, y: y + size * 0.16, width: 400, alpha: alpha)
    }
    /// Numaralı daire (kaydırmalı gönderilerde adım numarası).
    func badge(_ n: Int, x: CGFloat, y: CGFloat, color: NSColor, size: CGFloat = 76) {
        ctx.setFillColor(color.cgColor); ctx.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        text("\(n)", Kit.font("ExtraBold", size * 0.48), Kit.hex(0x0A0F1E), x: x, y: y + size * 0.2, width: size, align: .center)
    }
}
