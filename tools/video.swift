// Reels üreticisi.
//   video render <social kökü> <fonts> <ikon> <id> <çıktı.mp4>   → plan.json'daki reel şablonunu sessiz çizer
//   video mux <video> <ses.m4a> <çıktı.mp4>                         → müziği ekler (sonda kısılarak)
//   video cover <video> <saniye> <çıktı.jpg>                        → kapak karesi
import AVFoundation
import AppKit

let A = CommandLine.arguments
let VW: CGFloat = 1080, VH: CGFloat = 1920, FPS: Int32 = 30

func ease(_ t: CGFloat) -> CGFloat { let x = max(0, min(1, t)); return 1 - pow(1 - x, 3) }

// MARK: - Sahneler

struct Scene {
    let duration: Double
    let draw: (Surface, CGFloat, Double) -> Void   // yüzey, sahne içi 0…1, sahne içi saniye
}

func titleScene(_ eyebrow: String, _ title: String, accent: NSColor, duration: Double = 1.8, variant: Int = 0) -> Scene {
    Scene(duration: duration) { s, p, _ in
        s.background(s.glowsFor(accent, variant))
        let a = ease(p * 3), dy = 50 * (1 - a)
        s.text(eyebrow, Kit.font("Bold", 34), accent, x: 80, y: 660 + dy, width: 920, kern: 6, alpha: a)
        s.text(title, Kit.font("ExtraBold", 120), Kit.ink, x: 74, y: 720 + dy, width: 940, kern: -4, line: 0.98, alpha: a)
        s.brand(x: 80, y: 1740, size: 60, alpha: a)
    }
}
func captionText(_ s: Surface, _ caption: String, y: CGFloat, alpha: CGFloat) {
    s.text(caption, Kit.font("ExtraBold", 64), Kit.ink, x: 80, y: y, width: 920, kern: -1.5, line: 1.05, align: .center, alpha: alpha)
}
func imageScene(_ ref: String, _ caption: String, accent: NSColor, duration: Double = 2.4, variant: Int = 0) -> Scene {
    let img = Kit.cgImage(ref)
    return Scene(duration: duration) { s, p, _ in
        s.background(s.glowsFor(accent, variant))
        if let img { s.card(img, CGRect(x: 90, y: 200, width: 900, height: 1360), radius: 46, focusY: ref.hasPrefix("screens") ? 0.42 : 0.7, zoom: 1 + 0.08 * p) }
        captionText(s, caption, y: 1620, alpha: ease(p * 3))
    }
}
func phoneScene(_ screen: String, _ caption: String, accent: NSColor, duration: Double = 2.4, variant: Int = 0) -> Scene {
    let img = Kit.cgImage("screens/" + screen)
    return Scene(duration: duration) { s, p, _ in
        s.background(s.glowsFor(accent, variant))
        captionText(s, caption, y: 150, alpha: ease(p * 3))
        let rise = 260 * (1 - ease(p * 2.2))
        if let img { s.phone(img, CGRect(x: 230, y: 380 + rise, width: 620, height: 1348), angle: 3 * (1 - ease(p * 2))) }
    }
}
func ctaScene(_ title: String, accent: NSColor, duration: Double = 2.2) -> Scene {
    Scene(duration: duration) { s, p, _ in
        s.background(s.glowsFor(accent, 1))
        let a = ease(p * 2.5)
        let size: CGFloat = 260 * (0.85 + 0.15 * a)
        s.ctx.saveGState(); s.ctx.setAlpha(a)
        s.ctx.addPath(s.rounded(CGRect(x: (VW - size) / 2, y: 520, width: size, height: size), size * 0.23)); s.ctx.clip()
        s.drawFill(Kit.iconImage, in: CGRect(x: (VW - size) / 2, y: 520, width: size, height: size)); s.ctx.restoreGState()
        s.text(title, Kit.font("ExtraBold", 110), Kit.ink, x: 60, y: 860, width: 960, kern: -3.5, line: 0.98, align: .center, alpha: a)
        s.text("Kareyo · iOS'ta ücretsiz", Kit.font("SemiBold", 40), accent, x: 60, y: 1180, width: 960, align: .center, alpha: a)
        s.text("bağlantı profilde", Kit.font("Regular", 34), Kit.muted, x: 60, y: 1240, width: 960, align: .center, alpha: a)
    }
}
func seqFrame(_ seq: String, _ p: CGFloat, count: Int = 30) -> (CGImage?, Int) {
    let d = min(count, max(1, Int(p * CGFloat(count)) + 1))
    return (Kit.seq(seq, d), d)
}
/// Tam ekran fotoğraf üstündeki yazılar okunsun diye üstte ve altta koyu geçiş.
func shade(_ s: Surface) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [Kit.hex(0x0A0F1E, 0.7).cgColor, Kit.hex(0x0A0F1E, 0).cgColor, Kit.hex(0x0A0F1E, 0).cgColor, Kit.hex(0x0A0F1E, 0.8).cgColor] as CFArray, locations: [0, 0.28, 0.66, 1])!
    s.ctx.drawLinearGradient(g, start: .zero, end: CGPoint(x: 0, y: VH), options: [])
}
func focus(for seq: String) -> CGFloat { seq.hasPrefix("sakal") ? 0.42 : 0.75 }

// MARK: - Şablonlar

func scenes(for r: [String: Any]) -> [Scene] {
    let t = r["template"] as! String
    switch t {
    case "reel-product":
        let list = r["scenes"] as! [[String: Any]]
        let accents = [Kit.gold, Kit.mint, Kit.coral, Kit.blue]
        return list.enumerated().map { i, sc in
            let a = accents[i % accents.count]
            switch sc["kind"] as! String {
            case "title": return titleScene(sc["eyebrow"] as? String ?? "", sc["title"] as? String ?? "", accent: a, variant: i)
            case "image": return imageScene(sc["image"] as! String, sc["caption"] as? String ?? "", accent: a, variant: i)
            case "phone": return phoneScene(sc["screen"] as! String, sc["caption"] as? String ?? "", accent: a, variant: i)
            default: return ctaScene(sc["title"] as? String ?? "", accent: Kit.gold)
            }
        }
    case "reel-compare":
        let l = r["left"] as! String, rr = r["right"] as! String
        let play = Scene(duration: 6.5) { s, p, _ in
            s.background(s.glowsFor(Kit.mint, 0))
            s.text(r["title"] as? String ?? "", Kit.font("ExtraBold", 84), Kit.ink, x: 70, y: 150, width: 940, kern: -2.5, align: .center)
            let pp = min(1, p * 1.15)
            let (a, d) = seqFrame(l, pp), (b, _) = seqFrame(rr, pp)
            let cl = CGRect(x: 50, y: 330, width: 480, height: 1180), cr = CGRect(x: 550, y: 330, width: 480, height: 1180)
            if let a { s.card(a, cl, radius: 34, focusY: 0.72, zoom: 1.35) }
            if let b { s.card(b, cr, radius: 34, focusY: 0.72, zoom: 1.35) }
            s.chip(r["leftLabel"] as? String ?? "", x: 74, y: 356, size: 26, dark: true)
            s.chip(r["rightLabel"] as? String ?? "", x: 574, y: 356, color: Kit.mint, size: 26, dark: true)
            s.text("Gün \(d)", Kit.font("ExtraBold", 72), Kit.ink, x: 60, y: 1560, width: 960, align: .center)
        }
        return [titleScene("SİHİRLİ HİZALAMA", "Telefon\nher gün kayar.", accent: Kit.mint), play, ctaScene("Titreme\nyok.", accent: Kit.mint)]
    case "reel-triptych":
        let seqs = r["sequences"] as! [String], labels = r["labels"] as! [String]
        let play = Scene(duration: 6.5) { s, p, _ in
            s.background(s.glowsFor(Kit.gold, 2))
            let pp = min(1, p * 1.15)
            var day = 1
            for (i, seq) in seqs.enumerated() {
                let (img, d) = seqFrame(seq, pp); day = d
                let rect = CGRect(x: 40 + CGFloat(i) * 340, y: 300, width: 320, height: 1200)
                if let img { s.card(img, rect, radius: 30, focusY: 0.72, zoom: 1.25) }
                s.text(labels[i], Kit.font("Bold", 32), Kit.ink, x: rect.minX, y: 1530, width: rect.width, align: .center)
            }
            s.text("Gün \(day)", Kit.font("ExtraBold", 96), Kit.ink, x: 60, y: 140, width: 960, align: .center)
        }
        return [titleScene("3 BİTKİ", "Aynı 30 gün.", accent: Kit.gold), play, ctaScene("Sıradaki\nsenin.", accent: Kit.gold)]
    case "reel-grid":
        let seq = r["sequence"] as! String
        let build = Scene(duration: 4.6) { s, p, _ in
            s.background(s.glowsFor(Kit.mint, 0))
            s.text(r["title"] as? String ?? "", Kit.font("ExtraBold", 80), Kit.ink, x: 60, y: 170, width: 960, kern: -2, align: .center)
            let shown = Int(min(1, p * 1.25) * 30)
            let cols = 5, gap: CGFloat = 10, cw = (960 - gap * 4) / 5, ch = cw * 1.25
            for i in 0..<shown {
                guard let img = Kit.seq(seq, i + 1) else { continue }
                let rect = CGRect(x: 60 + CGFloat(i % cols) * (cw + gap), y: 340 + CGFloat(i / cols) * (ch + gap), width: cw, height: ch)
                s.ctx.saveGState(); s.ctx.addPath(s.rounded(rect, 14)); s.ctx.clip(); s.drawFill(img, in: rect, focusY: 0.75); s.ctx.restoreGState()
                s.text("\(i + 1)", Kit.font("Bold", 22), Kit.ink, x: rect.minX + 10, y: rect.minY + 8, width: 60)
            }
        }
        let play = Scene(duration: 3.6) { s, p, _ in
            let (img, d) = seqFrame(seq, min(1, p * 1.2))
            if let img { s.drawFill(img, in: CGRect(x: 0, y: 0, width: VW, height: VH), focusY: 0.6) }
            shade(s)
            s.text("GÜN", Kit.font("Bold", 36), Kit.ink, x: 84, y: 150, width: 400, kern: 8)
            s.text("\(d)", Kit.font("ExtraBold", 220), Kit.ink, x: 70, y: 180, width: 600, kern: -8)
        }
        return [build, play, ctaScene("Her gün\nbir kare.", accent: Kit.mint)]
    case "reel-montage":
        let seqs = r["sequences"] as! [String]
        let names = ["feslegen": "Fesleğen", "monstera": "Monstera", "pilea": "Pilea", "pothos": "Pothos", "sakal": "Sakal"]
        var list = [titleScene("12 HAFTA", "Her gün\nbir kare.", accent: Kit.gold)]
        for (i, seq) in seqs.enumerated() {
            list.append(Scene(duration: 2.3) { s, p, _ in
                let (img, d) = seqFrame(seq, min(1, p * 1.1))
                if let img { s.drawFill(img, in: CGRect(x: 0, y: 0, width: VW, height: VH), focusY: seq == "sakal" ? 0.4 : 0.6) }
                shade(s)
                s.chip(names[seq] ?? seq, x: 80, y: 150, color: [Kit.gold, Kit.mint, Kit.coral, Kit.blue, Kit.gold][i % 5], size: 34, dark: true)
                s.text("Gün \(d)", Kit.font("ExtraBold", 110), Kit.ink, x: 80, y: 1600, width: 900)
            })
        }
        list.append(ctaScene("Sıradaki\nsenin.", accent: Kit.gold))
        return list
    default:
        fatalError("bilinmeyen reel şablonu \(t)")
    }
}

// MARK: - Yazım

func render(_ list: [Scene], to path: String) {
    try? FileManager.default.removeItem(atPath: path)
    let writer = try! AVAssetWriter(outputURL: URL(fileURLWithPath: path), fileType: .mp4)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: VW, AVVideoHeightKey: VH,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 12_000_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel]
    ])
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB, kCVPixelBufferWidthKey as String: VW, kCVPixelBufferHeightKey as String: VH
    ])
    writer.add(input); writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let fade = 0.28
    var frame: Int64 = 0
    var previousLast: CGImage?
    for scene in list {
        let n = Int(scene.duration * Double(FPS))
        var last: CGImage?
        for i in 0..<n {
            autoreleasepool {
                let t = Double(i) / Double(FPS)
                let off = Surface(VW, VH)
                scene.draw(off, CGFloat(Double(i) / Double(max(n - 1, 1))), t)
                var img = off.ctx.makeImage()!
                if let prev = previousLast, t < fade {
                    let mix = Surface(VW, VH)
                    mix.drawFill(prev, in: CGRect(x: 0, y: 0, width: VW, height: VH))
                    mix.drawFill(img, in: CGRect(x: 0, y: 0, width: VW, height: VH), alpha: CGFloat(t / fade))
                    img = mix.ctx.makeImage()!
                }
                last = img
                while !input.isReadyForMoreMediaData { usleep(2000) }
                var pb: CVPixelBuffer?
                CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
                CVPixelBufferLockBaseAddress(pb!, [])
                let ctx = CGContext(data: CVPixelBufferGetBaseAddress(pb!), width: Int(VW), height: Int(VH), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pb!), space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
                ctx.draw(img, in: CGRect(x: 0, y: 0, width: VW, height: VH))
                CVPixelBufferUnlockBaseAddress(pb!, [])
                adaptor.append(pb!, withPresentationTime: CMTime(value: frame, timescale: FPS))
                frame += 1
            }
        }
        previousLast = last
    }
    input.markAsFinished()
    let sem = DispatchSemaphore(value: 0)
    writer.finishWriting { sem.signal() }
    sem.wait()
    print("render", path, Double(frame) / Double(FPS), "sn")
}

func mux(video: String, audio: String, out: String) {
    let v = AVURLAsset(url: URL(fileURLWithPath: video)), a = AVURLAsset(url: URL(fileURLWithPath: audio))
    let comp = AVMutableComposition()
    let vt = v.tracks(withMediaType: .video).first!
    let dur = v.duration
    let cv = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try! cv.insertTimeRange(CMTimeRange(start: .zero, duration: dur), of: vt, at: .zero)
    let ca = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let at = a.tracks(withMediaType: .audio).first!
    try! ca.insertTimeRange(CMTimeRange(start: .zero, duration: CMTimeMinimum(dur, a.duration)), of: at, at: .zero)
    let params = AVMutableAudioMixInputParameters(track: ca)
    let fadeStart = CMTimeSubtract(dur, CMTime(seconds: 1.2, preferredTimescale: 600))
    params.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: CMTimeRange(start: fadeStart, duration: CMTime(seconds: 1.2, preferredTimescale: 600)))
    let mix = AVMutableAudioMix(); mix.inputParameters = [params]
    try? FileManager.default.removeItem(atPath: out)
    let ex = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetHighestQuality)!
    ex.outputURL = URL(fileURLWithPath: out); ex.outputFileType = .mp4; ex.audioMix = mix
    let sem = DispatchSemaphore(value: 0)
    ex.exportAsynchronously { sem.signal() }
    sem.wait()
    print("mux", out, ex.status == .completed ? "ok" : "HATA \(String(describing: ex.error))")
}

func cover(video: String, seconds: Double, out: String) {
    let gen = AVAssetImageGenerator(asset: AVURLAsset(url: URL(fileURLWithPath: video)))
    gen.requestedTimeToleranceBefore = .zero; gen.requestedTimeToleranceAfter = .zero
    let img = try! gen.copyCGImage(at: CMTime(seconds: seconds, preferredTimescale: 600), actualTime: nil)
    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, "public.jpeg" as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
    CGImageDestinationFinalize(dest)
}

switch A[1] {
case "render":
    Kit.setup(root: A[2], fonts: A[3], icon: A[4])
    let plan = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: Kit.root + "/content/plan.json"))) as! [String: Any]
    let item = (plan["items"] as! [[String: Any]]).first { $0["id"] as? String == A[5] }!
    render(scenes(for: item["render"] as! [String: Any]), to: A[6])
case "mux": mux(video: A[2], audio: A[3], out: A[4])
case "cover": cover(video: A[2], seconds: Double(A[3])!, out: A[4])
default: print("komut?")
}
