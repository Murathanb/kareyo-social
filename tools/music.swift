// Telifsiz arka plan müziği: tamamen sentezlenen lo-fi parça (pad + bas + arpej + davul).
// Kullanım: music <stil: sakin|parlak|hareketli> <saniye> <çıktı.m4a>
import AVFoundation
import Foundation

let style = CommandLine.arguments[1]
let seconds = Double(CommandLine.arguments[2])!
let outPath = CommandLine.arguments[3]
let sr = 44_100.0
let n = Int(seconds * sr)
var left = [Float](repeating: 0, count: n), right = [Float](repeating: 0, count: n)

func midi(_ m: Double) -> Double { 440 * pow(2, (m - 69) / 12) }
struct Style { let bpm: Double; let chords: [[Double]]; let drums: Bool; let swing: Double; let pluckOctave: Double }
let styles: [String: Style] = [
    // Fmaj7 – Em7 – Dm7 – Cmaj7
    "sakin": Style(bpm: 80, chords: [[53, 57, 60, 64], [52, 55, 59, 62], [50, 53, 57, 60], [48, 52, 55, 59]], drums: true, swing: 0.56, pluckOctave: 12),
    // Am7 – Fmaj7 – C – G
    "parlak": Style(bpm: 92, chords: [[57, 60, 64, 67], [53, 57, 60, 64], [48, 52, 55, 60], [55, 59, 62, 67]], drums: true, swing: 0.55, pluckOctave: 12),
    // C – G – Am – F
    "hareketli": Style(bpm: 108, chords: [[48, 52, 55, 60], [55, 59, 62, 67], [57, 60, 64, 69], [53, 57, 60, 65]], drums: true, swing: 0.52, pluckOctave: 12),
]
let st = styles[style]!
let beat = 60 / st.bpm, bar = beat * 4
var seed: UInt64 = 1234
func rnd() -> Float { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return Float((seed >> 33) % 100000) / 50000 - 1 }

func add(_ start: Double, _ dur: Double, pan: Float = 0, _ sample: (Double) -> Double) {
    let s = max(0, Int(start * sr)), e = min(n, Int((start + dur) * sr))
    guard s < e else { return }
    let lg = Float(min(1, 1 - Double(pan))), rg = Float(min(1, 1 + Double(pan)))
    for i in s..<e { let v = Float(sample(Double(i) / sr - start)); left[i] += v * lg; right[i] += v * rg }
}

var t = 0.0, chordIndex = 0
while t < seconds {
    let chord = st.chords[chordIndex % st.chords.count]
    // Pad: yumuşak atak, bir sonraki akora taşan sönüş.
    for (k, note) in chord.enumerated() {
        let f = midi(note)
        for detune in [-0.0018, 0.0018] {
            add(t, bar + 0.8, pan: detune < 0 ? -0.35 : 0.35) { x in
                let env = min(1, x / 0.35) * (x > bar ? max(0, 1 - (x - bar) / 0.8) : 1)
                let ph = 2 * Double.pi * f * (1 + detune) * x
                return 0.045 * env * (sin(ph) + 0.28 * sin(2 * ph) + 0.1 * sin(3 * ph)) * (k == 0 ? 0.8 : 1)
            }
        }
    }
    // Bas: 1. ve 3. vuruş
    for b in [0.0, 2.0] {
        let f = midi(chord[0] - 12)
        add(t + b * beat, beat * 1.8) { x in 0.2 * exp(-x / 0.55) * (sin(2 * .pi * f * x) + 0.2 * sin(4 * .pi * f * x)) }
    }
    // Arpej: sekizlikler, swing
    for e in 0..<8 {
        let off = Double(e / 2) * beat + (e % 2 == 1 ? beat * st.swing : 0)
        let note = chord[[0, 2, 1, 3, 2, 1, 3, 2][e]] + st.pluckOctave
        let f = midi(note)
        add(t + off, 0.9, pan: e % 2 == 0 ? -0.25 : 0.25) { x in 0.05 * exp(-x / 0.22) * (sin(2 * .pi * f * x) + 0.15 * sin(4 * .pi * f * x)) }
    }
    if st.drums && t > 0.01 || st.drums && style == "hareketli" {
        for b in 0..<4 {
            let bt = t + Double(b) * beat
            if b == 0 || b == 2 {
                add(bt, 0.4) { x in
                    let f = 45 + 70 * exp(-x / 0.04)
                    return 0.42 * exp(-x / 0.13) * sin(2 * .pi * f * x)
                }
            } else {
                var last: Float = 0
                add(bt, 0.25) { x in
                    let nz = rnd(); let hp = nz - last; last = nz
                    return 0.09 * exp(-x / 0.07) * Double(hp) + 0.05 * exp(-x / 0.05) * sin(2 * .pi * 190 * x)
                }
            }
            // hi-hat: sekizlik ara vuruş
            var last: Float = 0
            add(bt + beat * st.swing, 0.08, pan: 0.3) { _ in
                let nz = rnd(); let hp = nz - last; last = nz
                return 0.035 * Double(hp)
            }
        }
    }
    t += bar; chordIndex += 1
}
// Plak hışırtısı
for i in 0..<n {
    let c = rnd()
    let crackle: Float = c > 0.9993 ? rnd() * 0.08 : 0
    left[i] += crackle + rnd() * 0.004; right[i] += crackle + rnd() * 0.004
}
// Yumuşak sınırlama, normalize, giriş/çıkış
var peak: Float = 0
for i in 0..<n { left[i] = tanh(left[i] * 1.2); right[i] = tanh(right[i] * 1.2); peak = max(peak, abs(left[i]), abs(right[i])) }
let gain = 0.89 / max(peak, 0.001)
for i in 0..<n {
    let x = Double(i) / sr
    let fade = Float(min(1, x / 0.3) * min(1, (seconds - x) / 1.2))
    left[i] *= gain * fade; right[i] *= gain * fade
}

let format = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(n))!
buffer.frameLength = AVAudioFrameCount(n)
for i in 0..<n { buffer.floatChannelData![0][i] = left[i]; buffer.floatChannelData![1][i] = right[i] }
try? FileManager.default.removeItem(atPath: outPath)
// Dosya kapsam bitince kapanıp sonlandırılıyor (üst düzey değişken olsaydı hiç kapanmazdı).
func writeFile() {
    let file = try! AVAudioFile(forWriting: URL(fileURLWithPath: outPath), settings: [
        AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: sr, AVNumberOfChannelsKey: 2, AVEncoderBitRateKey: 192_000
    ])
    try! file.write(from: buffer)
}
writeFile()
print("ok", outPath)
