// Tanıtım içerikleri için 30 günlük "değişim" dizileri üretir (çizim, gerçek fotoğraf değil).
// Kullanım: scenes <varyant> <çıktı klasörü>   varyant: pothos | monstera | feslegen | sakal
// Her gün kadraj elde çekim gibi biraz kayar — Sihirli Hizalama'yı göstermek için.
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let W: CGFloat = 1080, H: CGFloat = 2340
let cs = CGColorSpaceCreateDeviceRGB()
struct RNG { var s: UInt64; mutating func next() -> CGFloat { s = s &* 6364136223846793005 &+ 1442695040888963407; return CGFloat((s >> 33) % 100000) / 100000 } }
func rgb(_ h: UInt32, _ a: CGFloat = 1) -> CGColor { CGColor(red: CGFloat((h >> 16) & 255)/255, green: CGFloat((h >> 8) & 255)/255, blue: CGFloat(h & 255)/255, alpha: a) }
func grad(_ c: CGContext, _ colors: [CGColor], _ a: CGPoint, _ b: CGPoint) {
    let g = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: nil)!
    c.drawLinearGradient(g, start: a, end: b, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}
func smooth(_ e0: CGFloat, _ e1: CGFloat, _ x: CGFloat) -> CGFloat { let t = max(0, min(1, (x - e0) / (e1 - e0))); return t * t * (3 - 2 * t) }

func heartLeaf(_ s: CGFloat, width: CGFloat = 1) -> CGPath {
    let p = CGMutablePath(); let k = width
    p.move(to: .zero)
    p.addCurve(to: CGPoint(x: -0.56*s*k, y: -0.42*s), control1: CGPoint(x: -0.18*s*k, y: 0.14*s), control2: CGPoint(x: -0.62*s*k, y: -0.02*s))
    p.addCurve(to: CGPoint(x: 0, y: -s), control1: CGPoint(x: -0.5*s*k, y: -0.8*s), control2: CGPoint(x: -0.14*s*k, y: -0.9*s))
    p.addCurve(to: CGPoint(x: 0.56*s*k, y: -0.42*s), control1: CGPoint(x: 0.14*s*k, y: -0.9*s), control2: CGPoint(x: 0.5*s*k, y: -0.8*s))
    p.addCurve(to: .zero, control1: CGPoint(x: 0.62*s*k, y: -0.02*s), control2: CGPoint(x: 0.18*s*k, y: 0.14*s))
    return p
}
func ovalLeaf(_ s: CGFloat) -> CGPath {
    let p = CGMutablePath()
    p.move(to: .zero)
    p.addCurve(to: CGPoint(x: 0, y: -s), control1: CGPoint(x: -0.55*s, y: -0.2*s), control2: CGPoint(x: -0.4*s, y: -0.85*s))
    p.addCurve(to: .zero, control1: CGPoint(x: 0.4*s, y: -0.85*s), control2: CGPoint(x: 0.55*s, y: -0.2*s))
    return p
}

struct Room { var wallTop: UInt32; var wallBottom: UInt32; var table: Bool }

/// Elde çekim kayması + ortam (duvar, pencere ışığı, masa). Konu `body` içinde çizilir.
func frame(day: Int, room: Room, seed: UInt64, body: (CGContext, inout RNG) -> Void) -> CGImage {
    let c = CGContext(data: nil, width: Int(W), height: Int(H), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    c.translateBy(x: 0, y: H); c.scaleBy(x: 1, y: -1)
    var r = RNG(s: seed &+ UInt64(day * 31))
    let jx = day == 0 ? 0 : (r.next() - 0.5) * 80, jy = day == 0 ? 0 : (r.next() - 0.5) * 70
    let js = day == 0 ? 1 : 0.97 + r.next() * 0.06, jr = day == 0 ? 0 : (r.next() - 0.5) * 0.025
    let sun = 0.78 + r.next() * 0.32
    c.saveGState(); c.clip(to: CGRect(x: 0, y: 0, width: W, height: H))
    grad(c, [rgb(room.wallTop), rgb(room.wallBottom)], .zero, CGPoint(x: 0, y: H)); c.restoreGState()
    c.saveGState()
    c.translateBy(x: W/2 + jx, y: H/2 + jy); c.rotate(by: jr); c.scaleBy(x: js, y: js); c.translateBy(x: -W/2, y: -H/2)
    let light = CGMutablePath()
    light.move(to: CGPoint(x: 120, y: -200)); light.addLine(to: CGPoint(x: 760, y: -200)); light.addLine(to: CGPoint(x: 1240, y: 1500)); light.addLine(to: CGPoint(x: 560, y: 1500)); light.closeSubpath()
    c.saveGState(); c.addPath(light); c.clip()
    grad(c, [rgb(0xFFF6E3, 0.5 * sun), rgb(0xFFF1D6, 0)], CGPoint(x: 400, y: 0), CGPoint(x: 900, y: 1500)); c.restoreGState()
    if room.table {
        c.saveGState(); c.clip(to: CGRect(x: -300, y: 1660, width: W + 600, height: H))
        grad(c, [rgb(0xC39466), rgb(0x8A5F3D)], CGPoint(x: 0, y: 1660), CGPoint(x: 0, y: H + 300)); c.restoreGState()
        c.setFillColor(rgb(0x000000, 0.10)); c.fill(CGRect(x: -200, y: 1655, width: W + 400, height: 8))
        for k in 0..<7 { c.setFillColor(rgb(0x5A3A22, 0.06)); c.fill(CGRect(x: -200, y: 1720 + CGFloat(k) * 110, width: W + 400, height: 3)) }
    }
    body(c, &r)
    c.restoreGState()
    c.setFillColor(rgb(sun > 1 ? 0xFFF4E0 : 0x1A1F2E, abs(sun - 0.92) * 0.16)); c.fill(CGRect(x: 0, y: 0, width: W, height: H))
    for _ in 0..<5000 { c.setFillColor(rgb(r.next() > 0.5 ? 0xFFFFFF : 0x000000, 0.035)); c.fill(CGRect(x: r.next() * W, y: r.next() * H, width: 2, height: 2)) }
    return c.makeImage()!
}

func pot(_ c: CGContext, colors: [UInt32], rim: [UInt32], scale: CGFloat = 1) {
    let cx: CGFloat = 540, top: CGFloat = 1640, w = 410 * scale, bw = 320 * scale, h = 360 * scale
    c.setFillColor(rgb(0x3B2414, 0.28)); c.fillEllipse(in: CGRect(x: cx - w * 0.68, y: top + h - 40, width: w * 1.36, height: 90))
    let body = CGMutablePath()
    body.move(to: CGPoint(x: cx - w/2, y: top)); body.addLine(to: CGPoint(x: cx + w/2, y: top)); body.addLine(to: CGPoint(x: cx + bw/2, y: top + h))
    body.addQuadCurve(to: CGPoint(x: cx - bw/2, y: top + h), control: CGPoint(x: cx, y: top + h + 30)); body.closeSubpath()
    c.saveGState(); c.addPath(body); c.clip(); grad(c, colors.map { rgb($0) }, CGPoint(x: cx - w/2, y: 0), CGPoint(x: cx + w/2, y: 0)); c.restoreGState()
    let rimRect = CGRect(x: cx - w/2 - 25 * scale, y: top - 55 * scale, width: w + 50 * scale, height: 92 * scale)
    c.saveGState(); c.addPath(CGPath(roundedRect: rimRect, cornerWidth: 18, cornerHeight: 18, transform: nil)); c.clip()
    grad(c, rim.map { rgb($0) }, CGPoint(x: rimRect.minX, y: 0), CGPoint(x: rimRect.maxX, y: 0)); c.restoreGState()
    c.setFillColor(rgb(0x3A2516)); c.fillEllipse(in: CGRect(x: cx - w/2 + 3, y: top - 62 * scale, width: w - 6, height: 34 * scale))
}

func shadeLeaf(_ c: CGContext, _ path: CGPath, size: CGFloat, color: UInt32, veins: Bool = true) {
    c.saveGState()
    c.setShadow(offset: CGSize(width: 6, height: 10), blur: 18, color: rgb(0x1E2A12, 0.25))
    c.addPath(path); c.setFillColor(rgb(color)); c.fillPath()
    c.restoreGState()
    c.saveGState(); c.addPath(path); c.clip()
    grad(c, [rgb(0xB8E39A, 0.32), rgb(0x000000, 0), rgb(0x0C2410, 0.25)], CGPoint(x: -size * 0.5, y: -size), CGPoint(x: size * 0.5, y: 0))
    c.restoreGState()
    guard veins else { return }
    c.setStrokeColor(rgb(0xCFE8B4, 0.5)); c.setLineWidth(max(2, size * 0.016))
    c.move(to: CGPoint(x: 0, y: -size * 0.04)); c.addQuadCurve(to: CGPoint(x: 0, y: -size * 0.92), control: CGPoint(x: size * 0.04, y: -size * 0.5)); c.strokePath()
}

// MARK: - Varyantlar

func pothos(_ day: Int, _ g: CGFloat) -> CGImage {
    frame(day: day, room: Room(wallTop: 0xEEF0EC, wallBottom: 0xD9DDD6, table: true), seed: 2000) { c, _ in
        var s = RNG(s: 77)
        let base = CGPoint(x: 540, y: 1600)
        // Sarkan ve yükselen gövdeler; yapraklar gövde boyunca diziliyor.
        for i in 0..<12 {
            let birth = CGFloat(i) * 0.06
            let grow = smooth(birth, birth + 0.5, g)
            guard grow > 0.02 else { continue }
            let side: CGFloat = i % 2 == 0 ? -1 : 1
            let trailing = i >= 6
            let angle = side * (0.15 + CGFloat(i % 6) * 0.16)
            let len = (trailing ? 620 : 420 + s.next() * 120) * (0.2 + 0.8 * grow)
            let tip = trailing
                ? CGPoint(x: base.x + side * (220 + CGFloat(i % 3) * 60) * grow, y: base.y + len * 0.55)
                : CGPoint(x: base.x + sin(angle) * len, y: base.y - cos(angle) * len)
            let ctrl = trailing ? CGPoint(x: base.x + side * 260 * grow, y: base.y - 120) : CGPoint(x: base.x + sin(angle) * len * 0.4, y: base.y - len * 0.7)
            c.setStrokeColor(rgb(0x4E7F3A)); c.setLineWidth(7); c.setLineCap(.round)
            c.move(to: base); c.addQuadCurve(to: tip, control: ctrl); c.strokePath()
            let leaves = max(1, Int(CGFloat(trailing ? 6 : 4) * grow))
            for k in 0..<leaves {
                let t = CGFloat(k + 1) / CGFloat(leaves + (trailing ? 0 : 0))
                let mt = 1 - t
                let p = CGPoint(x: mt*mt*base.x + 2*mt*t*ctrl.x + t*t*tip.x, y: mt*mt*base.y + 2*mt*t*ctrl.y + t*t*tip.y)
                let size = (130 + s.next() * 40) * (0.35 + 0.65 * smooth(birth + CGFloat(k) * 0.04, birth + 0.45 + CGFloat(k) * 0.04, g))
                c.saveGState(); c.translateBy(x: p.x, y: p.y)
                c.rotate(by: side * (trailing ? 2.2 + CGFloat(k % 2) * 0.5 : 0.6 + CGFloat(k % 2) * 0.4))
                let leaf = heartLeaf(size, width: 0.9)
                shadeLeaf(c, leaf, size: size, color: [0x3C8A3E, 0x2F7A38, 0x47964A][k % 3])
                // altın renkli alacalar
                c.saveGState(); c.addPath(leaf); c.clip()
                c.setStrokeColor(rgb(0xF2D86B, 0.55)); c.setLineWidth(size * 0.05)
                c.move(to: CGPoint(x: -size * 0.15, y: -size * 0.2)); c.addQuadCurve(to: CGPoint(x: -size * 0.3, y: -size * 0.6), control: CGPoint(x: -size * 0.35, y: -size * 0.3)); c.strokePath()
                c.restoreGState()
                c.restoreGState()
            }
        }
        pot(c, colors: [0x88A9BE, 0x5E7F96, 0x3F5A70], rim: [0x9DBBCE, 0x6E8FA6, 0x47637A])
    }
}

func monstera(_ day: Int, _ g: CGFloat) -> CGImage {
    frame(day: day, room: Room(wallTop: 0xF1ECE6, wallBottom: 0xDFD5C9, table: true), seed: 3000) { c, _ in
        let base = CGPoint(x: 540, y: 1600)
        let spec: [(CGFloat, CGFloat, CGFloat)] = [(-0.12, 760, 380), (0.32, 700, 360), (-0.5, 620, 330), (0.62, 560, 300), (0.05, 520, 260), (-0.8, 470, 240), (0.88, 430, 220)]
        for (i, v) in spec.enumerated().reversed() {
            let birth = CGFloat(i) * 0.11
            let grow = smooth(birth, birth + 0.45, g)
            guard grow > 0.02 else { continue }
            let len = v.1 * (0.3 + 0.7 * grow)
            let tip = CGPoint(x: base.x + sin(v.0) * len, y: base.y - cos(v.0) * len)
            let ctrl = CGPoint(x: base.x + sin(v.0) * len * 0.35, y: base.y - cos(v.0) * len * 0.7)
            c.setStrokeColor(rgb(0x4A7A35)); c.setLineWidth(11); c.setLineCap(.round)
            c.move(to: base); c.addQuadCurve(to: tip, control: ctrl); c.strokePath()
            let maturity = smooth(birth + 0.05, birth + 0.6, g)
            let size = v.2 * (0.2 + 0.8 * maturity)
            c.saveGState(); c.translateBy(x: tip.x, y: tip.y); c.rotate(by: v.0 * 0.7 + (v.0 > 0 ? 0.25 : -0.25))
            let leaf = heartLeaf(size, width: 1.15)
            c.beginTransparencyLayer(auxiliaryInfo: nil)
            shadeLeaf(c, leaf, size: size, color: [0x1F5E32, 0x24693A, 0x1B5530][i % 3])
            // Olgun yapraklarda monstera yarıkları (kenardan içe boşluklar).
            if maturity > 0.55 {
                c.setBlendMode(.clear); c.setLineCap(.round)
                // Damarlar boyunca, kenardan orta damara doğru eğik yarıklar + birkaç delik.
                let slits = maturity > 0.8 ? 4 : 3
                for k in 0..<slits {
                    let y = -size * (0.2 + CGFloat(k) * 0.17)
                    for side: CGFloat in [-1, 1] {
                        c.setLineWidth(size * 0.055)
                        c.move(to: CGPoint(x: side * size * 0.24, y: y))
                        c.addLine(to: CGPoint(x: side * size * 0.9, y: y - size * 0.2)); c.strokePath()
                        if maturity > 0.85, k < 2 {
                            c.fillEllipse(in: CGRect(x: side * size * 0.13 - size * 0.025, y: y - size * 0.1, width: size * 0.05, height: size * 0.07))
                        }
                    }
                }
                c.setBlendMode(.normal)
            }
            c.endTransparencyLayer()
            c.restoreGState()
        }
        pot(c, colors: [0xF4F2EC, 0xD9D6CC, 0xADA99E], rim: [0xFAF8F3, 0xDEDBD2, 0xB3AFA4], scale: 1.08)
    }
}

func feslegen(_ day: Int, _ g: CGFloat) -> CGImage {
    frame(day: day, room: Room(wallTop: 0xF4EEE2, wallBottom: 0xE6D9C3, table: true), seed: 4000) { c, _ in
        var s = RNG(s: 91)
        let stems: [(CGFloat, CGFloat)] = [(0, 520), (-0.22, 430), (0.26, 450), (-0.45, 330), (0.5, 340)]
        for (i, st) in stems.enumerated() {
            let birth = 0.1 + CGFloat(i) * 0.08     // ilk günler yalnızca toprak
            let grow = smooth(birth, birth + 0.6, g)
            guard grow > 0.01 else { continue }
            let base = CGPoint(x: 540 + CGFloat(i - 2) * 26, y: 1600)
            let len = st.1 * grow
            let tip = CGPoint(x: base.x + sin(st.0) * len, y: base.y - cos(st.0) * len)
            c.setStrokeColor(rgb(0x6E9E45)); c.setLineWidth(5 + 3 * grow); c.setLineCap(.round)
            c.move(to: base); c.addLine(to: tip); c.strokePath()
            let pairs = max(1, Int(1 + 4 * grow))
            for k in 0..<pairs {
                let t = 1 - CGFloat(k) / CGFloat(pairs + 1) * 0.9
                let p = CGPoint(x: base.x + (tip.x - base.x) * t, y: base.y + (tip.y - base.y) * t)
                let size = (60 + 70 * grow) * (1 - CGFloat(k) * 0.08) * (0.7 + s.next() * 0.3)
                for side: CGFloat in [-1, 1] {
                    c.saveGState(); c.translateBy(x: p.x, y: p.y); c.rotate(by: st.0 + side * (0.9 + CGFloat(k % 2) * 0.2))
                    shadeLeaf(c, ovalLeaf(size), size: size, color: [0x4E9B3A, 0x5AAA45][k % 2])
                    c.restoreGState()
                }
            }
        }
        pot(c, colors: [0xD98257, 0xB4603C, 0x86422A], rim: [0xE38D61, 0xBF6943, 0x8F462C], scale: 0.85)
    }
}

func sakal(_ day: Int, _ g: CGFloat) -> CGImage {
    frame(day: day, room: Room(wallTop: 0xC9D3DE, wallBottom: 0xA9B6C4, table: false), seed: 5000) { c, r in
        let cx: CGFloat = 540
        // Omuzlar ve gömlek
        let shirt = CGMutablePath()
        shirt.move(to: CGPoint(x: 40, y: H + 200)); shirt.addCurve(to: CGPoint(x: cx, y: 1520), control1: CGPoint(x: 60, y: 1650), control2: CGPoint(x: 300, y: 1540))
        shirt.addCurve(to: CGPoint(x: 1040, y: H + 200), control1: CGPoint(x: 780, y: 1540), control2: CGPoint(x: 1020, y: 1650)); shirt.closeSubpath()
        c.saveGState(); c.addPath(shirt); c.clip(); grad(c, [rgb(0x34506F), rgb(0x22374F)], CGPoint(x: 0, y: 1500), CGPoint(x: 0, y: H)); c.restoreGState()
        // Boyun
        c.setFillColor(rgb(0xD9A27E)); c.fill(CGRect(x: cx - 120, y: 1250, width: 240, height: 330))
        c.setFillColor(rgb(0xB9835F, 0.6)); c.fillEllipse(in: CGRect(x: cx - 130, y: 1480, width: 260, height: 110))
        // Kulaklar ve yüz
        let skin = [rgb(0xF0BF9B), rgb(0xE3AC86)]
        for side: CGFloat in [-1, 1] { c.setFillColor(rgb(0xE0A983)); c.fillEllipse(in: CGRect(x: cx + side * 265 - 45, y: 930, width: 90, height: 150)) }
        let face = CGPath(ellipseIn: CGRect(x: cx - 255, y: 640, width: 510, height: 720), transform: nil)
        c.saveGState(); c.addPath(face); c.clip(); grad(c, skin, CGPoint(x: cx - 255, y: 700), CGPoint(x: cx + 255, y: 1300)); c.restoreGState()
        // Saç
        let hair = CGMutablePath()
        hair.move(to: CGPoint(x: cx - 262, y: 960)); hair.addCurve(to: CGPoint(x: cx, y: 600), control1: CGPoint(x: cx - 300, y: 700), control2: CGPoint(x: cx - 150, y: 590))
        hair.addCurve(to: CGPoint(x: cx + 262, y: 960), control1: CGPoint(x: cx + 150, y: 590), control2: CGPoint(x: cx + 300, y: 700))
        hair.addCurve(to: CGPoint(x: cx - 262, y: 960), control1: CGPoint(x: cx + 200, y: 760), control2: CGPoint(x: cx - 200, y: 720)); hair.closeSubpath()
        c.addPath(hair); c.setFillColor(rgb(0x3A2A20)); c.fillPath()
        // Kaşlar, gözler, burun, ağız
        c.setStrokeColor(rgb(0x3A2A20)); c.setLineWidth(16); c.setLineCap(.round)
        for side: CGFloat in [-1, 1] {
            c.move(to: CGPoint(x: cx + side * 160, y: 905)); c.addQuadCurve(to: CGPoint(x: cx + side * 60, y: 900), control: CGPoint(x: cx + side * 110, y: 880)); c.strokePath()
            c.setFillColor(rgb(0xFFFFFF)); c.fillEllipse(in: CGRect(x: cx + side * 110 - 42, y: 950, width: 84, height: 46))
            c.setFillColor(rgb(0x3B2B22)); c.fillEllipse(in: CGRect(x: cx + side * 110 - 20, y: 953, width: 40, height: 40))
        }
        c.setStrokeColor(rgb(0xC08A66)); c.setLineWidth(9)
        c.move(to: CGPoint(x: cx + 6, y: 990)); c.addQuadCurve(to: CGPoint(x: cx - 18, y: 1130), control: CGPoint(x: cx + 30, y: 1080)); c.strokePath()
        // Sakal bölgesi: favoriler → çene; bıyık ayrı
        let beard = CGMutablePath()
        beard.move(to: CGPoint(x: cx - 250, y: 960))
        beard.addCurve(to: CGPoint(x: cx, y: 1372), control1: CGPoint(x: cx - 250, y: 1230), control2: CGPoint(x: cx - 150, y: 1372))
        beard.addCurve(to: CGPoint(x: cx + 250, y: 960), control1: CGPoint(x: cx + 150, y: 1372), control2: CGPoint(x: cx + 250, y: 1230))
        beard.addLine(to: CGPoint(x: cx + 205, y: 1060))
        beard.addCurve(to: CGPoint(x: cx - 205, y: 1060), control1: CGPoint(x: cx + 140, y: 1290), control2: CGPoint(x: cx - 140, y: 1290))
        beard.closeSubpath()
        let mustache = CGMutablePath()
        mustache.move(to: CGPoint(x: cx - 120, y: 1185)); mustache.addQuadCurve(to: CGPoint(x: cx + 120, y: 1185), control: CGPoint(x: cx, y: 1125))
        mustache.addQuadCurve(to: CGPoint(x: cx - 120, y: 1185), control: CGPoint(x: cx, y: 1160)); mustache.closeSubpath()
        let density = 0.05 + 0.85 * smooth(0.0, 1.0, g)
        for region in [beard, mustache] {
            c.saveGState(); c.addPath(region); c.clip()
            c.setFillColor(rgb(0x3A2A20, density * 0.75)); c.fill(CGRect(x: 0, y: 0, width: W, height: H))
            let strokes = Int(400 + 5200 * g)
            c.setStrokeColor(rgb(0x2B1E16, 0.55)); c.setLineWidth(3)
            for _ in 0..<strokes {
                let x = cx - 260 + r.next() * 520, y = 950 + r.next() * 430
                let l = 5 + 22 * g
                c.move(to: CGPoint(x: x, y: y)); c.addLine(to: CGPoint(x: x + (r.next() - 0.5) * 6, y: y + l)); c.strokePath()
            }
            c.restoreGState()
        }
        // Dudaklar sakalın üstünde
        c.setStrokeColor(rgb(0xA45A4A)); c.setLineWidth(12)
        c.move(to: CGPoint(x: cx - 75, y: 1212)); c.addQuadCurve(to: CGPoint(x: cx + 75, y: 1212), control: CGPoint(x: cx, y: 1232)); c.strokePath()
    }
}

let variant = CommandLine.arguments[1], out = CommandLine.arguments[2]
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
let total = 30
for d in 0..<total {
    let g = CGFloat(d) / CGFloat(total - 1)
    let image: CGImage
    switch variant {
    case "pothos": image = pothos(d, g)
    case "monstera": image = monstera(d, g)
    case "feslegen": image = feslegen(d, g)
    case "sakal": image = sakal(d, g)
    default: fatalError("bilinmeyen varyant")
    }
    let url = URL(fileURLWithPath: "\(out)/day\(String(format: "%02d", d + 1)).jpg") as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.jpeg.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: 0.92] as CFDictionary)
    CGImageDestinationFinalize(dest)
}
print(variant, "ok")
