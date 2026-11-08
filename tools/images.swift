// plan.json'daki görsel, kaydırmalı ve hikâye öğelerini content/media/<id>/NN.jpg olarak üretir.
// Kullanım: images <social kökü> <fonts> <ikon> [id ...]
import AppKit

let args = CommandLine.arguments
Kit.setup(root: args[1], fonts: args[2], icon: args[3])
let only = Set(args.dropFirst(4))
let plan = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: Kit.root + "/content/plan.json"))) as! [String: Any]
let items = plan["items"] as! [[String: Any]]
let mediaRoot = Kit.root + "/content/media"

let FW: CGFloat = 1080, FH: CGFloat = 1350, SW: CGFloat = 1080, SH: CGFloat = 1920
func out(_ id: String) -> String { let d = "\(mediaRoot)/\(id)"; try? FileManager.default.createDirectory(atPath: d, withIntermediateDirectories: true); return d }
func clear(_ id: String) { let d = out(id); for f in (try? FileManager.default.contentsOfDirectory(atPath: d)) ?? [] where f.hasSuffix(".jpg") && f != "cover.jpg" { try? FileManager.default.removeItem(atPath: "\(d)/\(f)") } }
func str(_ d: [String: Any], _ k: String) -> String { d[k] as? String ?? "" }
func focus(for seq: String) -> CGFloat { seq.hasPrefix("sakal") ? 0.42 : 0.78 }
func seqName(_ ref: String) -> String { String(ref.split(separator: "/").first ?? "") }

// MARK: - Akış şablonları

func announce(_ r: [String: Any], _ s: Surface, variant: Int) {
    let accent = Kit.accent(r["accent"] as? String)
    s.background(s.glowsFor(accent, variant))
    s.text(str(r, "eyebrow"), Kit.font("Bold", 24), accent, x: 80, y: 86, width: 900, kern: 4)
    let hh = s.text(str(r, "headline"), Kit.font("ExtraBold", 80), Kit.ink, x: 76, y: 130, width: 560, kern: -2.5, line: 1.0)
    s.text(str(r, "body"), Kit.font("Regular", 28), Kit.muted, x: 80, y: 130 + hh + 28, width: 470, line: 1.3)
    if let img = Kit.cgImage("screens/" + str(r, "screen")) { s.phone(img, CGRect(x: 590, y: 200, width: 420, height: 913), angle: 4) }
    s.brand(x: 80, y: 1250, size: 54)
}

func quote(_ r: [String: Any], _ s: Surface, variant: Int) {
    let accent = Kit.accent(r["accent"] as? String)
    if let ref = r["image"] as? String, let img = Kit.cgImage(ref) {
        s.drawFill(img, in: CGRect(x: 0, y: 0, width: s.w, height: s.h), focusY: focus(for: ref))
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [Kit.hex(0x0A0F1E, 0.15).cgColor, Kit.hex(0x0A0F1E, 0.92).cgColor] as CFArray, locations: [0.2, 0.75])!
        s.ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: s.h), options: [])
    } else { s.background(s.glowsFor(accent, variant)) }
    let q = str(r, "quote")
    let f = Kit.font("ExtraBold", 74)
    let h = s.textHeight(q, f, width: 920, kern: -2, line: 1.02)
    s.ctx.setFillColor(accent.cgColor); s.ctx.fill(CGRect(x: 80, y: 1150 - h - 70, width: 70, height: 8))
    s.text(q, f, Kit.ink, x: 76, y: 1150 - h - 30, width: 920, kern: -2, line: 1.02)
    s.brand(x: 80, y: 1230, size: 54)
}

func beforeAfter(_ r: [String: Any], _ s: Surface) {
    let seq = str(r, "sequence")
    let l = r["left"] as? Int ?? 1, rr = r["right"] as? Int ?? 30
    let aligned = Kit.cgImage("\(seq)-aligned/day01") != nil ? "\(seq)-aligned" : seq
    let half = s.w / 2
    if let a = Kit.seq(aligned, l) { s.drawFill(a, in: CGRect(x: 0, y: 0, width: half, height: s.h), focusY: focus(for: seq)) }
    if let b = Kit.seq(aligned, rr) { s.drawFill(b, in: CGRect(x: half, y: 0, width: half, height: s.h), focusY: focus(for: seq)) }
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [Kit.hex(0x0A0F1E, 0.85).cgColor, Kit.hex(0x0A0F1E, 0).cgColor] as CFArray, locations: [0, 1])!
    s.ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: 360), options: [])
    s.ctx.setFillColor(NSColor.white.cgColor); s.ctx.fill(CGRect(x: half - 3, y: 0, width: 6, height: s.h))
    s.ctx.fillEllipse(in: CGRect(x: half - 34, y: s.h / 2 - 34, width: 68, height: 68))
    s.text("‹ ›", Kit.font("Bold", 30), Kit.hex(0x0A0F1E), x: half - 34, y: s.h / 2 - 22, width: 68, align: .center)
    s.text(str(r, "headline"), Kit.font("ExtraBold", 70), Kit.ink, x: 70, y: 80, width: 940, kern: -2)
    s.chip("GÜN \(l)", x: 60, y: 1190, size: 26, dark: true)
    s.chip("GÜN \(rr)", x: s.w - 60, y: 1190, size: 26, dark: true, alignRight: true)
}

func grid30(_ r: [String: Any], _ s: Surface, x0: CGFloat, y0: CGFloat, width: CGFloat, cols: Int = 6, seq: String, count: Int = 30) {
    let gap: CGFloat = 8
    let cw = (width - gap * CGFloat(cols - 1)) / CGFloat(cols), ch = cw * 1.25
    for i in 0..<count {
        guard let img = Kit.seq(seq, i + 1) else { continue }
        let rect = CGRect(x: x0 + CGFloat(i % cols) * (cw + gap), y: y0 + CGFloat(i / cols) * (ch + gap), width: cw, height: ch)
        s.ctx.saveGState(); s.ctx.addPath(s.rounded(rect, 12)); s.ctx.clip(); s.drawFill(img, in: rect, focusY: focus(for: seq)); s.ctx.restoreGState()
        s.text("\(i + 1)", Kit.font("Bold", 18), Kit.ink, x: rect.minX + 10, y: rect.minY + 8, width: 60)
    }
}

func grid30Post(_ r: [String: Any], _ s: Surface, variant: Int) {
    s.background(s.glowsFor(Kit.mint, variant))
    s.text(str(r, "headline"), Kit.font("ExtraBold", 76), Kit.ink, x: 76, y: 70, width: 940, kern: -2)
    s.text(str(r, "body"), Kit.font("SemiBold", 28), Kit.muted, x: 80, y: 168, width: 940)
    grid30(r, s, x0: 60, y0: 240, width: 960, seq: str(r, "sequence"))
    s.brand(x: 80, y: 1262, size: 50)
}

func question(_ r: [String: Any], _ s: Surface, variant: Int) {
    s.background(s.glowsFor(Kit.gold, variant))
    s.text("SORU", Kit.font("Bold", 24), Kit.gold, x: 80, y: 86, width: 900, kern: 4)
    s.text(str(r, "headline"), Kit.font("ExtraBold", 80), Kit.ink, x: 76, y: 130, width: 940, kern: -2.5, line: 1.0)
    let opts = r["options"] as? [String] ?? []
    for (i, o) in opts.enumerated() {
        let rect = CGRect(x: 80 + CGFloat(i % 2) * 470, y: 470 + CGFloat(i / 2) * 330, width: 450, height: 300)
        s.glass(rect, radius: 34, alpha: 0.1)
        let parts = o.split(separator: " ", maxSplits: 1).map(String.init)
        s.text(parts.first ?? "", Kit.font("Regular", 90), Kit.ink, x: rect.minX + 36, y: rect.minY + 40, width: 200)
        s.text(parts.count > 1 ? parts[1] : "", Kit.font("Bold", 36), Kit.ink, x: rect.minX + 36, y: rect.minY + 190, width: rect.width - 60)
    }
    s.text("Yorumlara yaz 👇", Kit.font("SemiBold", 30), Kit.muted, x: 80, y: 1150, width: 600)
    s.brand(x: 80, y: 1250, size: 50)
}

// MARK: - Kaydırmalı

func slide(_ sl: [String: Any], index: Int, total: Int, accent: NSColor, _ s: Surface) {
    let kind = str(sl, "kind")
    s.background(s.glowsFor(accent, index))
    switch kind {
    case "cover":
        if let ref = sl["image"] as? String, let img = Kit.cgImage(ref) {
            s.card(img, CGRect(x: 80, y: 560, width: 920, height: 680), radius: 40, focusY: focus(for: ref))
        } else {
            // Görselsiz kapak: soluk, büyük "1 → 30" tipografisi.
            s.text("1 → 30", Kit.font("ExtraBold", 300), accent.withAlphaComponent(0.16), x: 40, y: 700, width: 1100, kern: -12)
        }
        s.text(str(sl, "eyebrow"), Kit.font("Bold", 24), accent, x: 80, y: 86, width: 900, kern: 4)
        s.text(str(sl, "title"), Kit.font("ExtraBold", 88), Kit.ink, x: 76, y: 132, width: 940, kern: -3, line: 0.98)
    case "text":
        let n = sl["n"] as? Int ?? index
        s.text(String(format: "%02d", n), Kit.font("ExtraBold", 480), accent.withAlphaComponent(0.13), x: 380, y: 640, width: 760, kern: -24)
        s.badge(n, x: 80, y: 180, color: accent)
        let th = s.text(str(sl, "title"), Kit.font("ExtraBold", 66), Kit.ink, x: 80, y: 300, width: 900, kern: -1.5, line: 1.02)
        s.text(str(sl, "body"), Kit.font("Regular", 36), Kit.muted, x: 80, y: 300 + th + 30, width: 860, line: 1.32)
    case "screen", "onion", "image":
        let n = sl["n"] as? Int ?? index
        s.badge(n, x: 80, y: 90, color: accent, size: 64)
        let th = s.text(str(sl, "title"), Kit.font("ExtraBold", 54), Kit.ink, x: 168, y: 92, width: 830, kern: -1, line: 1.02)
        s.text(str(sl, "body"), Kit.font("Regular", 29), Kit.muted, x: 80, y: max(170, 92 + th + 20), width: 920, line: 1.3)
        if kind == "screen" {
            if let ref = sl["screen"] as? String, let img = Kit.cgImage("screens/" + ref) {
                s.phone(img, CGRect(x: 300, y: 380, width: 480, height: 1043))
            } else if let ref = sl["image"] as? String, let img = Kit.cgImage(ref) {
                s.card(img, CGRect(x: 160, y: 380, width: 760, height: 1100), radius: 40, focusY: 0.35)
            }
        } else if kind == "onion" {
            let seq = str(sl, "sequence"), aligned = sl["aligned"] as? Bool ?? false
            let src = aligned && Kit.cgImage("\(seq)-aligned/day01") != nil ? "\(seq)-aligned" : seq
            let a = Kit.seq(src, sl["a"] as? Int ?? 1), b = Kit.seq(src, sl["b"] as? Int ?? 2)
            let rect = CGRect(x: 140, y: 380, width: 800, height: 900)
            s.ctx.saveGState(); s.ctx.setShadow(offset: CGSize(width: 0, height: 24), blur: 60, color: NSColor.black.withAlphaComponent(0.5).cgColor)
            s.ctx.addPath(s.rounded(rect, 40)); s.ctx.setFillColor(NSColor.black.cgColor); s.ctx.fillPath(); s.ctx.restoreGState()
            s.ctx.saveGState(); s.ctx.addPath(s.rounded(rect, 40)); s.ctx.clip()
            if let a { s.drawFill(a, in: rect, focusY: focus(for: seq)) }
            if let b { s.drawFill(b, in: rect, focusY: focus(for: seq), alpha: 0.5) }
            s.ctx.restoreGState()
            s.chip(aligned ? "Hizalı" : "Üst üste", x: 170, y: 410, color: aligned ? Kit.mint : Kit.ink, size: 24, dark: true)
        } else if let g = sl["grid"] as? String {
            grid30(sl, s, x0: 160, y0: 330, width: 760, seq: g)
        }
    case "cta":
        s.ctx.saveGState(); s.ctx.addPath(s.rounded(CGRect(x: 420, y: 330, width: 240, height: 240), 56)); s.ctx.clip()
        s.drawFill(Kit.iconImage, in: CGRect(x: 420, y: 330, width: 240, height: 240)); s.ctx.restoreGState()
        s.text(str(sl, "title"), Kit.font("ExtraBold", 84), Kit.ink, x: 80, y: 640, width: 920, kern: -2.5, line: 1.0, align: .center)
        let body = str(sl, "body")
        let f = Kit.font("SemiBold", 28)
        let bw = (body as NSString).size(withAttributes: [.font: f]).width + 56
        s.chip(body, x: (s.w - bw) / 2, y: 900, color: accent, size: 28)
    default: break
    }
    // Alt bilgi: sayfa noktaları + kaydır
    let dotsW = CGFloat(total) * 22
    for i in 0..<total {
        s.ctx.setFillColor((i == index ? accent : NSColor.white.withAlphaComponent(0.25)).cgColor)
        s.ctx.fillEllipse(in: CGRect(x: s.w / 2 - dotsW / 2 + CGFloat(i) * 22, y: 1296, width: 10, height: 10))
    }
    if index < total - 1 { s.text("kaydır →", Kit.font("SemiBold", 24), Kit.muted, x: s.w - 300, y: 1282, width: 220, align: .right) }
    if kind != "cta" { s.text("kareyo", Kit.font("Bold", 24), Kit.muted, x: 80, y: 1282, width: 200) }
}

// MARK: - Hikâyeler

func firstImage(of postId: String) -> CGImage? {
    for name in ["cover.jpg", "01.jpg"] { if let i = Kit.cgImage("\(mediaRoot)/\(postId)/\(name)") { return i } }
    return nil
}

func story(_ r: [String: Any], _ s: Surface, variant: Int) {
    let t = str(r, "template")
    switch t {
    case "story-newpost":
        s.background(s.glowsFor(Kit.gold, variant))
        s.text("YENİ GÖNDERİ", Kit.font("Bold", 30), Kit.gold, x: 80, y: 200, width: 900, kern: 6)
        if let img = firstImage(of: str(r, "post")) {
            let ratio = CGFloat(img.height) / CGFloat(img.width)
            let w: CGFloat = ratio > 1.5 ? 640 : 820
            s.card(img, CGRect(x: (s.w - w) / 2, y: 320, width: w, height: min(1180, w * ratio)), angle: -2, radius: 40)
        }
        s.text("Profilde seni bekliyor 👆", Kit.font("ExtraBold", 54), Kit.ink, x: 80, y: 1560, width: 920, kern: -1, align: .center)
        s.brand(x: 420, y: 1720, size: 64)
    case "story-question":
        s.background(s.glowsFor(Kit.mint, variant))
        s.text("BUGÜN", Kit.font("Bold", 30), Kit.mint, x: 80, y: 360, width: 900, kern: 6)
        s.text(str(r, "headline"), Kit.font("ExtraBold", 96), Kit.ink, x: 76, y: 420, width: 940, kern: -3, line: 1.0)
        for (i, o) in (r["options"] as? [String] ?? []).enumerated() {
            let rect = CGRect(x: 80, y: 860 + CGFloat(i) * 200, width: 920, height: 160)
            s.glass(rect, radius: 80, alpha: 0.12)
            s.text(o, Kit.font("Bold", 50), Kit.ink, x: rect.minX, y: rect.minY + 46, width: rect.width, align: .center)
        }
        s.text(str(r, "footer"), Kit.font("SemiBold", 36), Kit.muted, x: 80, y: 1320, width: 920, align: .center)
        s.brand(x: 420, y: 1720, size: 64)
    case "story-streak":
        let seq = str(r, "sequence"), frame = r["frame"] as? Int ?? 1
        if let img = Kit.seq(seq, frame) { s.drawFill(img, in: CGRect(x: 0, y: 0, width: s.w, height: s.h), focusY: 0.6) }
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [Kit.hex(0x0A0F1E, 0.75).cgColor, Kit.hex(0x0A0F1E, 0).cgColor, Kit.hex(0x0A0F1E, 0).cgColor, Kit.hex(0x0A0F1E, 0.9).cgColor] as CFArray, locations: [0, 0.3, 0.6, 1])!
        s.ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: s.h), options: [])
        s.text(str(r, "headline"), Kit.font("Bold", 40), Kit.gold, x: 80, y: 200, width: 920, kern: 2)
        s.text("GÜN", Kit.font("Bold", 36), Kit.ink.withAlphaComponent(0.8), x: 84, y: 1360, width: 400, kern: 8)
        s.text("\(frame)", Kit.font("ExtraBold", 260), Kit.ink, x: 70, y: 1390, width: 600, kern: -10)
        s.text("/30", Kit.font("Bold", 80), Kit.gold, x: frame >= 10 ? 400 : 250, y: 1555, width: 300)
        s.text(frame == 30 ? "Tamamlandı 🎉" : "Seri devam ediyor 🔥", Kit.font("SemiBold", 40), Kit.ink, x: 80, y: 1720, width: 900)
    case "story-tip":
        s.background(s.glowsFor(Kit.coral, variant))
        s.text("İPUCU #\(r["n"] as? Int ?? 1)", Kit.font("Bold", 30), Kit.coral, x: 80, y: 520, width: 900, kern: 6)
        s.text(str(r, "tip"), Kit.font("ExtraBold", 88), Kit.ink, x: 76, y: 580, width: 920, kern: -2.5, line: 1.02)
        s.text("Kaydet, yarın dene 🔖", Kit.font("SemiBold", 36), Kit.muted, x: 80, y: 1420, width: 920)
        s.brand(x: 420, y: 1720, size: 64)
    default: break
    }
}

// MARK: - Çalıştır

var count = 0
for (idx, item) in items.enumerated() {
    let id = item["id"] as! String
    if !only.isEmpty && !only.contains(id) { continue }
    let kind = item["kind"] as! String
    let r = item["render"] as! [String: Any]
    let t = str(r, "template")
    if kind == "reel" { continue }
    clear(id)
    let dir = out(id)
    if kind == "story" {
        let s = Surface(SW, SH); story(r, s, variant: idx); s.saveJPEG("\(dir)/01.jpg"); count += 1
        continue
    }
    switch t {
    case "file":
        let s = Surface(FW, FH)
        if let img = Kit.cgImage(str(r, "path")) { s.drawFill(img, in: CGRect(x: 0, y: 0, width: FW, height: FH)) }
        s.saveJPEG("\(dir)/01.jpg")
    case "carousel":
        let slides = r["slides"] as! [[String: Any]]
        let accent = Kit.accent(r["accent"] as? String)
        for (i, sl) in slides.enumerated() {
            let s = Surface(FW, FH); slide(sl, index: i, total: slides.count, accent: accent, s)
            s.saveJPEG("\(dir)/\(String(format: "%02d", i + 1)).jpg")
        }
    default:
        let s = Surface(FW, FH)
        switch t {
        case "announce": announce(r, s, variant: idx)
        case "quote": quote(r, s, variant: idx)
        case "beforeafter": beforeAfter(r, s)
        case "grid30": grid30Post(r, s, variant: idx)
        case "question": question(r, s, variant: idx)
        default: print("bilinmeyen şablon", t, id)
        }
        s.saveJPEG("\(dir)/01.jpg")
    }
    count += 1
}
print("görsel öğe:", count)
