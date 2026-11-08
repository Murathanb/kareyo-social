"""Kareyo Instagram — 12 haftalık içerik planı (tek doğruluk kaynağı).

Çalıştırınca content/plan.json üretir. Görsel/video üreticileri ve otomatik paylaşım
betiği bu dosyayı okur.

Gün hesabı: `day` başlangıç tarihine (config.json → start_date) göre gün farkı.
Gün 0 = başlangıç ızgarası (9 gönderi art arda). Hafta w'nin pazartesisi = 1 + (w-1)*7;
bu yüzden start_date bir PAZAR olmalı.
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WD = {"pzt": 0, "sal": 1, "car": 2, "per": 3, "cum": 4, "cmt": 5, "paz": 6}


def day(week, wd):
    return 1 + (week - 1) * 7 + WD[wd]


TAGS = {
    "genel": "#kareyo #hergünbirkare #değişim #timelapse",
    "bitki": "#bitki #bitkibakımı #plantsofinstagram #evbitkileri",
    "ipucu": "#fotoğrafipuçları #iphonefotoğrafçılığı",
    "aliskanlik": "#alışkanlık #motivasyon #disiplin",
    "kareyo30": "#kareyo30 #30günmeydanokuması",
}


def tags(*keys):
    return " ".join(TAGS[k] for k in keys)


items = []


def add(id, d, time, kind, pillar, caption, render, notes=None):
    items.append({"id": id, "day": d, "time": time, "kind": kind, "pillar": pillar,
                  "caption": caption.strip(), "render": render, "notes": notes})


# ---------------------------------------------------------------- Gün 0 · Başlangıç ızgarası
# Profilde en yeni gönderi solda üstte görünür: sıralama, ızgarada üst satır 7-8-9 olacak şekilde.
add("g01", 0, "10:00", "reel", "dönüşüm", f"""
Tohumdan 30 gün. 🌱 Her gün tek bir kare, sonuç 10 saniye.

Kareyo ile her gün aynı kareyi çekiyorsun; gerisini uygulama hallediyor: kareleri hizalıyor, gün sayacını ekliyor, videoyu kurguluyor.

Sen hangi değişimi izlemek isterdin? 👇

{tags("genel", "bitki")}
""", {"template": "reel-sequence", "sequence": "feslegen", "title": "Fesleğen", "frames": 30, "music": "sakin"})

add("g02", 0, "10:05", "image", "ürün", f"""
Kareyo'ya hoş geldin. 👋

Kareyo, değişimini her gün tek bir fotoğrafla kaydetmen için tasarlandı: kilo, fitness, bitki, evcil hayvan, saç ya da sakal.

• Her gün bir kare, aynı açıdan
• Dünkü kare hayalet katman olarak üstte
• Sonunda tek dokunuşla timelapse ve Reels
• Fotoğrafların yalnızca telefonunda 🔒

iOS'ta ücretsiz, bağlantı profilde.

{tags("genel")}
""", {"template": "announce", "eyebrow": "MERHABA", "headline": "Her gün\nbir kare.", "body": "Değişimini fotoğrafla kaydet,\nzamanla izle.", "screen": "home", "accent": "gold"})

add("g03", 0, "10:10", "carousel", "ipucu", f"""
Timelapse'in neden titriyor? 5 kuralla her gün aynı kareyi yakala. 🔖

Kaydet, yarın sabah dene. Hangi kural sana yeni geldi? Yorumlara yaz.

{tags("genel", "ipucu")}
""", {"template": "carousel", "accent": "mint", "slides": [
    {"kind": "cover", "eyebrow": "İPUCU", "title": "Aynı kareyi\nyakalamanın\n5 kuralı", "image": "pilea/day30"},
    {"kind": "text", "n": 1, "title": "Hep aynı saatte çek", "body": "Işık değişirse her şey değişir. Bir saat seç ve ona sadık kal; Kareyo o saatte hatırlatır."},
    {"kind": "text", "n": 2, "title": "Aynı yerde dur", "body": "Yere küçük bir bant yapıştır ya da duvardaki bir noktayı referans al."},
    {"kind": "text", "n": 3, "title": "Dünkü kareyi üstüne koy", "body": "Kareyo kamerada dünkü fotoğrafını hayalet katman olarak gösterir. Çizgileri üst üste getir, çek."},
    {"kind": "text", "n": 4, "title": "Telefonu sabitle", "body": "3 ya da 10 saniyelik zamanlayıcıyı aç, telefonu bir yere daya. El titremesi biter."},
    {"kind": "text", "n": 5, "title": "Gerisini hizalamaya bırak", "body": "Küçük kaymaları Sihirli Hizalama düzeltir: yüzü, bedeni ya da sahneyi bulur, kareleri aynı kadraja oturtur."},
    {"kind": "cta", "title": "Hepsi tek\nuygulamada.", "body": "Kaydet 🔖 · bağlantı profilde"},
]})

add("g04", 0, "10:15", "reel", "dönüşüm", f"""
30 günde Monstera. 🌿 İlk yaprak, ilk yarık, sonra bir orman.

Her gün aynı saatte, aynı yerden tek bir kare. Kareyo kareleri hizaladı ve videoyu kendisi kurguladı.

{tags("genel", "bitki")}
""", {"template": "reel-sequence", "sequence": "monstera", "title": "Monstera", "frames": 30, "music": "parlak"})

add("g05", 0, "10:20", "image", "dönüşüm", f"""
Gün 1 → Gün 30. Aynı saksı, aynı pencere, aynı açı.

Farkı yalnızca her gün çektiğinde görürsün. ✨

{tags("genel", "bitki")}
""", {"template": "beforeafter", "sequence": "pilea", "left": 1, "right": 30, "headline": "Gün 1 → Gün 30"})

add("g06", 0, "10:25", "carousel", "ürün", f"""
Kareyo nasıl çalışır? 4 adımda. 👇

1. Değişimini seç
2. Her gün bir kare çek
3. Hayalet katmanla hizala
4. Sonunda filmini izle

Bağlantı profilde.

{tags("genel")}
""", {"template": "carousel", "accent": "gold", "slides": [
    {"kind": "cover", "eyebrow": "NASIL ÇALIŞIR", "title": "4 adımda\nKareyo", "image": "monstera/day30"},
    {"kind": "screen", "n": 1, "title": "Değişimini seç", "body": "Kilo, fitness, bitki, evcil hayvan, saç/sakal ya da kendi kategorin. Süreyi belirle.", "screen": "home"},
    {"kind": "screen", "n": 2, "title": "Her gün bir kare", "body": "Hatırlatma gelir, kamera açılır. Gün sayacın ve serin büyür.", "screen": "detail"},
    {"kind": "screen", "n": 3, "title": "Önce / Sonra", "body": "İlk günle bugünü tek ekranda karşılaştır; perdeyi kaydır.", "screen": "compare"},
    {"kind": "screen", "n": 4, "title": "Filmini izle", "body": "Tek dokunuşla Reels: gün sayacı, Önce/Sonra perdesi ve müzik.", "screen": "reveal"},
    {"kind": "cta", "title": "Bugün\nGün 1 olsun.", "body": "iOS'ta ücretsiz · bağlantı profilde"},
]})

add("g07", 0, "10:30", "reel", "ürün", f"""
Gün bitmeden Kareyo hatırlatır. ⏳

Bugünün karesini çekmediysen kilit ekranında ve Dinamik Ada'da gece yarısına geri sayım başlar. Dokun, çek, seri devam etsin.

{tags("genel")}
""", {"template": "reel-product", "music": "hareketli", "scenes": [
    {"kind": "title", "eyebrow": "KAREYO", "title": "Seri bozulmasın."},
    {"kind": "image", "image": "screens/island", "caption": "Gün bitmeden geri sayım"},
    {"kind": "phone", "screen": "home", "caption": "Bugünün karesi seni bekliyor"},
    {"kind": "phone", "screen": "detail", "caption": "Çek, seri büyüsün 🔥"},
    {"kind": "cta", "title": "Her gün\nbir kare."},
]})

add("g08", 0, "10:35", "image", "topluluk", f"""
Yakında: #kareyo30 🗓️

30 gün boyunca her gün bir kare. Kilo, bitki, saç, sakal, evcil hayvanın; ne olursa.

Biz de katılıyoruz: bir pothos'u 30 gün boyunca çekeceğiz ve her hafta burada paylaşacağız. Sen de hazır ol.

{tags("genel", "kareyo30")}
""", {"template": "grid30", "sequence": "pothos", "headline": "#kareyo30", "body": "30 gün · 30 kare · yakında"})

add("g09", 0, "10:40", "carousel", "motivasyon", f"""
Neden 30 gün? 🧠

Değişim çoğu zaman günlük olarak görünmez; kendini kandırdığını düşünüp bırakırsın. Her gün bir kare, görünmeyeni görünür yapar.

Kaydet ve bırakmak üzereyken tekrar oku. 🔖

{tags("genel", "aliskanlik")}
""", {"template": "carousel", "accent": "coral", "slides": [
    {"kind": "cover", "eyebrow": "MOTİVASYON", "title": "Neden\n30 gün?", "image": "feslegen/day30"},
    {"kind": "text", "n": 1, "title": "Değişim günlük görünmez", "body": "Aynaya her gün bakınca farkı göremezsin. Kayıt tutunca görürsün."},
    {"kind": "text", "n": 2, "title": "Küçük adım, büyük seri", "body": "Günde 5 saniye. Bu kadar küçük bir adımı bırakmak zor."},
    {"kind": "text", "n": 3, "title": "Seri seni taşır", "body": "Zincir uzadıkça kırmak istemezsin. Kareyo serini her gün gösterir."},
    {"kind": "text", "n": 4, "title": "Sonunda kanıt var", "body": "30 gün sonra elinde 30 kare ve bir film olur. Kendine en iyi motivasyon."},
    {"kind": "cta", "title": "Bugün\nbaşla.", "body": "Kaydet 🔖 · bağlantı profilde"},
]})

# ---------------------------------------------------------------- Hafta 1-2 · Lansman (1.2)
add("w1-pzt", day(1, "pzt"), "19:00", "image", "ürün", f"""
Kareyo 1.2 burada. ✨

Her gün bir kare çekiyorsun; artık gerisini Kareyo hallediyor:

🎬 Tek dokunuşla Reels: değişimin müziğe göre kesilmiş, paylaşmaya hazır bir videoya dönüşüyor.
🪄 Sihirli Hizalama: telefon her gün biraz kaysa da kareler aynı kadrajda kalıyor.
🤝 Birlikte Değiş: partnerinle ya da arkadaşınla ekip kur, ortak serinizi birlikte büyütün.

App Store'dan güncelle, bugünün karesini çek.

{tags("genel")}
""", {"template": "file", "path": "launch/01-lansman-4x5"}, "1.2 App Store'da yayında olmalı.")

add("w1-car", day(1, "car"), "20:30", "reel", "ürün", f"""
30 gün, tek pilea, her gün bir kare. 🌱

Bu videoyu Kareyo kendisi yaptı: kareleri hizaladı, gün sayacını ve Önce/Sonra perdesini ekledi. Yeni Tek Dokunuşla Reels ile senin değişimin de bir dokunuşla Reels oluyor.

{tags("genel", "bitki")}
""", {"template": "reel-file", "path": "launch/kareyo-reels-pilea", "music": "parlak"})

add("w1-cum", day(1, "cum"), "19:00", "image", "ürün", f"""
30 gün. 10 saniye. Paylaşmaya hazır. 🎬

Kareyo artık videonu kendisi kurguluyor: açılış başlığı, gün sayacı, Önce/Sonra perdesi ve kapanış kartı. Müzik eklersen kareler vuruşlara oturuyor.

Sen sadece her gün bir kare çek.

{tags("genel")} #reels
""", {"template": "file", "path": "launch/02-reels-4x5"})

add("w1-paz", day(1, "paz"), "19:00", "carousel", "ipucu", f"""
Hayalet katman nedir, nasıl kullanılır? 👻

Kareyo'nun kamerası dünkü fotoğrafını yarı saydam olarak gösterir. Kendini ya da konunu onunla üst üste getir, sonra çek. 3 adım:

{tags("genel", "ipucu")}
""", {"template": "carousel", "accent": "mint", "slides": [
    {"kind": "cover", "eyebrow": "İPUCU", "title": "Hayalet\nkatmanla\nhizala", "image": "sakal/day20"},
    {"kind": "onion", "n": 1, "title": "Dünkü kare üstte", "body": "Kamerayı açınca dünkü fotoğrafın yarı saydam görünür.", "sequence": "pilea", "a": 21, "b": 22, "aligned": False},
    {"kind": "text", "n": 2, "title": "Çizgileri eşle", "body": "Saksının kenarı, omuzların, çenen: belirgin bir çizgiyi seç ve dünküyle üst üste getir."},
    {"kind": "onion", "n": 3, "title": "Çek, Kareyo düzeltsin", "body": "Kalan küçük kaymayı Sihirli Hizalama halleder.", "sequence": "pilea", "a": 21, "b": 22, "aligned": True},
    {"kind": "cta", "title": "Kaydet,\nyarın dene.", "body": "🔖 · bağlantı profilde"},
]})

add("w2-pzt", day(2, "pzt"), "19:00", "image", "ürün", f"""
Telefon her gün biraz kayar. Kareyo düzeltir. 🪄

Sihirli Hizalama her karede yüzü, bedeni ya da sahneyi bulup tüm kareleri aynı kadraja oturtuyor. Timelapse'in titremiyor, Önce/Sonra karşılaştırman birebir örtüşüyor.

Hepsi cihazında; fotoğrafların hiçbir yere gönderilmiyor.

{tags("genel", "ipucu")}
""", {"template": "file", "path": "launch/03-sihirli-hizalama-4x5"})

add("w2-car", day(2, "car"), "20:30", "reel", "dönüşüm", f"""
30 gün tıraş yok. 🧔 Gün 1'den Gün 30'a, her gün aynı açıdan bir kare.

Sakal, saç, kaş… Yavaş değişen her şey için Kareyo.

{tags("genel")} #sakal #sakalbakımı #beard
""", {"template": "reel-sequence", "sequence": "sakal", "title": "Sakal", "frames": 30, "music": "hareketli"})

add("w2-cum", day(2, "cum"), "19:00", "image", "topluluk", f"""
Değişim, birlikte daha kolay. 🤝

Partnerinle, bir arkadaşınla ya da ailenle ekip kur. Her gün kimin karesini çektiğini görün, ortak serinizi birlikte büyütün. Unutan olursa tek dokunuşla dürt.

Fotoğrafların sende kalır; ekibin yalnızca gün ve seri bilgisini görür.

Bu yolculuğa kiminle çıkıyorsun? Etiketle 👇

{tags("genel")} #birliktedeğiş
""", {"template": "file", "path": "launch/04-birlikte-degis-4x5"})

add("w2-paz", day(2, "paz"), "19:00", "image", "dönüşüm", f"""
Gün 1 → Gün 30. Kaydır, farkı gör. 👀

İlk günle bugünü tek ekranda karşılaştır. Kareler birebir örtüşüyor; sadece değişim görünüyor.

Senin Gün 1'in ne? Bugün başla.

{tags("genel")} #öncesonra
""", {"template": "file", "path": "launch/05-once-sonra-4x5"})

# ---------------------------------------------------------------- Hafta 3-6 · #kareyo30
add("w3-pzt", day(3, "pzt"), "19:00", "carousel", "topluluk", f"""
#kareyo30 başlıyor! 🗓️ 30 gün, 30 kare.

Kurallar kaydırmalıda. Katılmak için:
1. Kareyo'da bir değişim başlat (30 gün)
2. Her gün bir kare çek
3. Hikâyende paylaşırken #kareyo30 ve @kareyo etiketle

30. günün sonunda en güzel değişimleri burada paylaşacağız (izninle).

{tags("genel", "kareyo30")}
""", {"template": "carousel", "accent": "gold", "slides": [
    {"kind": "cover", "eyebrow": "MEYDAN OKUMA", "title": "#kareyo30\nbaşlıyor", "image": "pothos/day01"},
    {"kind": "text", "n": 1, "title": "Bir değişim seç", "body": "Kilo, fitness, bitki, evcil hayvan, saç/sakal ya da kendi kategorin. Süre: 30 gün."},
    {"kind": "text", "n": 2, "title": "Her gün bir kare", "body": "Aynı saat, aynı yer, aynı açı. Bir günü kaçırırsan kaçırma hakkın seni korur."},
    {"kind": "text", "n": 3, "title": "Paylaş ve etiketle", "body": "Haftada bir hikâyende ilerlemeni paylaş: #kareyo30 ve @kareyo."},
    {"kind": "text", "n": 4, "title": "Gün 30'da filmini çıkar", "body": "Tek dokunuşla Reels ile değişimini paylaş. En güzelleri burada öne çıkaracağız."},
    {"kind": "cta", "title": "Biz de\nkatılıyoruz.", "body": "Pothos · her pazartesi ilerleme"},
]})

add("w3-car", day(3, "car"), "20:30", "reel", "topluluk", f"""
#kareyo30 Gün 1: biz de başladık. 🪴

Bir pothos, bir pencere, 30 gün. Her hafta ilerlemesini burada paylaşacağız. Sen ne çekiyorsun?

{tags("genel", "kareyo30", "bitki")}
""", {"template": "reel-product", "music": "parlak", "scenes": [
    {"kind": "title", "eyebrow": "#KAREYO30", "title": "Gün 1."},
    {"kind": "image", "image": "pothos/day01", "caption": "Bir saksı. Bir pencere."},
    {"kind": "title", "eyebrow": "KURAL", "title": "Her gün\naynı saatte\nbir kare."},
    {"kind": "image", "image": "pothos/day01", "caption": "Görüşmek üzere: Gün 7 👋"},
    {"kind": "cta", "title": "Sen de\nkatıl."},
]})

add("w3-cum", day(3, "cum"), "19:00", "image", "topluluk", f"""
Hangi değişimi takip ediyorsun? 👇

🏋️ Kilo / fitness
🌿 Bitki
🐶 Evcil hayvan
💇 Saç / sakal

Yorumlara emojisini bırak; en çok seçilen kategori için özel ipuçları hazırlayacağız.

{tags("genel", "kareyo30")}
""", {"template": "question", "headline": "Hangi değişimi\ntakip ediyorsun?", "options": ["🏋️ Kilo / fitness", "🌿 Bitki", "🐶 Evcil hayvan", "💇 Saç / sakal"]})

add("w4-pzt", day(4, "pzt"), "19:00", "carousel", "ipucu", f"""
Işık her şeydir. 💡 Değişimini aynı ışıkta çekmenin 4 yolu.

Kaydet, bu akşam dene. 🔖

{tags("genel", "ipucu")}
""", {"template": "carousel", "accent": "gold", "slides": [
    {"kind": "cover", "eyebrow": "İPUCU", "title": "Işık\nher şeydir", "image": "monstera/day22"},
    {"kind": "text", "n": 1, "title": "Gün ışığını sabitle", "body": "Pencereden gelen ışık saate göre değişir. Hatırlatma saatini her gün aynı tut."},
    {"kind": "text", "n": 2, "title": "Arkadan ışık alma", "body": "Pencereye sırtını değil yüzünü dön. Arkadan gelen ışık konuyu karartır."},
    {"kind": "text", "n": 3, "title": "Akşam çekiyorsan", "body": "Hep aynı lambayı aç, tavan ışığını ve flaşı kapat. Renk tonu sabit kalır."},
    {"kind": "text", "n": 4, "title": "Bulutlu güne üzülme", "body": "Küçük ışık farkları timelapse'e doğallık katar. Önemli olan her gün çekmek."},
    {"kind": "cta", "title": "Aynı ışık,\naynı saat.", "body": "Kaydet 🔖"},
]})

add("w4-car", day(4, "car"), "20:30", "reel", "topluluk", f"""
#kareyo30 Gün 7. 🌱 İlk yapraklar geldi!

Bir haftalık ilerleme: 7 gün, 7 kare. Sen kaçıncı gündesin? Yorumlara yaz.

{tags("genel", "kareyo30", "bitki")}
""", {"template": "reel-sequence", "sequence": "pothos", "title": "Pothos · 1. hafta", "frames": 7, "totalDays": 30, "music": "sakin"})

add("w4-cum", day(4, "cum"), "19:00", "image", "motivasyon", f"""
Mükemmel bir kare değil, her gün bir kare. 📸

Bugün dağınık saçla, kötü ışıkta, aceleyle çektiysen de sorun yok. Seriyi taşıyan şey mükemmellik değil, devamlılık.

{tags("genel", "aliskanlik")}
""", {"template": "quote", "quote": "Mükemmel bir kare değil,\nher gün bir kare.", "accent": "coral", "image": "feslegen/day18"})

add("w5-pzt", day(5, "pzt"), "19:00", "carousel", "ürün", f"""
Bir günü kaçırdın mı? Seri bitmedi. 🛟

Kareyo'da her değişim için bir kaçırma hakkın var: bir gün çekemezsen o gün korunur, serin devam eder. İki gün üst üste kaçırırsan değişim sona erer; bu yüzden hatırlatmaları açık tut.

{tags("genel", "kareyo30")}
""", {"template": "carousel", "accent": "mint", "slides": [
    {"kind": "cover", "eyebrow": "BİLİYOR MUYDUN", "title": "Bir gün\nkaçırınca\nne olur?", "image": "pothos/day12"},
    {"kind": "text", "n": 1, "title": "Kaçırma hakkın var", "body": "Her değişimde bir kaçırma hakkı var. Bir günü kaçırırsan o gün korunur, serin bozulmaz."},
    {"kind": "text", "n": 2, "title": "İki gün üst üste olmaz", "body": "İki gün üst üste kaçırırsan değişim sona erer. Kural sert ama seni tutan da bu."},
    {"kind": "screen", "n": 3, "title": "Gün bitmeden hatırlatır", "body": "Akşam saatlerinde hâlâ çekmediysen kilit ekranında geri sayım başlar.", "image": "screens/island"},
    {"kind": "cta", "title": "Seri\nsende.", "body": "Hatırlatmaları açık tut 🔔"},
]})

add("w5-car", day(5, "car"), "20:30", "reel", "topluluk", f"""
#kareyo30 Gün 14: yarı yol! 🪴

İki haftada iki yeni sürgün. Bu hafta seri nasıl gidiyor? 🔥

{tags("genel", "kareyo30", "bitki")}
""", {"template": "reel-sequence", "sequence": "pothos", "title": "Pothos · 2. hafta", "frames": 14, "totalDays": 30, "music": "parlak"})

add("w5-cum", day(5, "cum"), "19:00", "carousel", "ipucu", f"""
Bitkini fotoğraflıyorsan: 4 ipucu. 🌿

Bitkiler sabit durur ama yavaş değişir; o yüzden kadrajın her gün aynı olması en çok bitkilerde fark yaratır.

{tags("genel", "bitki", "ipucu")}
""", {"template": "carousel", "accent": "mint", "slides": [
    {"kind": "cover", "eyebrow": "KATEGORİ · BİTKİ", "title": "Bitkini\nçekmenin\n4 sırrı", "image": "pilea/day25"},
    {"kind": "text", "n": 1, "title": "Saksıyı işaretle", "body": "Saksının önüne küçük bir işaret koy; her gün aynı yönü kameraya çevir."},
    {"kind": "text", "n": 2, "title": "Biraz geniş çek", "body": "Bitki büyüyecek. İlk gün tepede ve yanlarda boşluk bırak."},
    {"kind": "text", "n": 3, "title": "Sulamadan önce çek", "body": "Yapraklar sulamadan sonra birkaç saat farklı durur. Rutini sabitle."},
    {"kind": "image", "n": 4, "title": "30 günün 30 karesi", "body": "Sonunda tek tek bakınca bile büyümeyi görürsün.", "grid": "pilea"},
    {"kind": "cta", "title": "Bitkin\nhazır mı?", "body": "Kaydet 🔖"},
]})

add("w6-pzt", day(6, "pzt"), "19:00", "carousel", "ipucu", f"""
Kilo ve fitness değişimini çekmenin doğru yolu. 🏋️

Vücut değişimi en çok kadraj ve poza duyarlıdır. 4 kural, net bir Önce/Sonra için:

{tags("genel", "ipucu")} #fitness #kilovermek #fitnessmotivasyon
""", {"template": "carousel", "accent": "coral", "slides": [
    {"kind": "cover", "eyebrow": "KATEGORİ · FİTNESS", "title": "Net bir\nÖnce/Sonra\niçin 4 kural", "image": None},
    {"kind": "text", "n": 1, "title": "Hep aynı poz", "body": "Önden, kollar yanda, ağırlık iki ayakta. Pozunu ilk gün belirle ve değiştirme."},
    {"kind": "text", "n": 2, "title": "Aynı saat, aç karnına", "body": "Sabah, kahvaltıdan önce. Gün içindeki şişkinlik farkları kayboluyor."},
    {"kind": "text", "n": 3, "title": "Zamanlayıcı + sabit telefon", "body": "Telefonu göğüs hizasında bir yere daya, 10 saniyelik zamanlayıcıyı aç."},
    {"kind": "text", "n": 4, "title": "Sayıyı da kaydet", "body": "Kareyo'da fotoğrafla birlikte kilonu ya da bel ölçünü girebilirsin; filmde kare kare görünür."},
    {"kind": "cta", "title": "Kanıt\nfotoğrafta.", "body": "Kaydet 🔖"},
]})

add("w6-car", day(6, "car"), "20:30", "reel", "topluluk", f"""
#kareyo30 Gün 21. 🌿 Pothos sarkmaya başladı!

Üç hafta, 21 kare. Bitiş çizgisi görünüyor. Sen de son haftaya giriyorsan yorumlara 🔥 bırak.

{tags("genel", "kareyo30", "bitki")}
""", {"template": "reel-sequence", "sequence": "pothos", "title": "Pothos · 3. hafta", "frames": 21, "totalDays": 30, "music": "hareketli"})

add("w6-cum", day(6, "cum"), "19:00", "image", "motivasyon", f"""
Son 9 gün. Şimdi bırakma. 💪

Çoğu kişi tam sonuçlar görünmeye başlarken bırakıyor. Serin buraya kadar geldiyse, bitiş çizgisi senin.

{tags("genel", "kareyo30", "aliskanlik")}
""", {"template": "quote", "quote": "Sonuçlar görünmeye\nbaşladığında\nbırakma.", "accent": "gold", "image": "pothos/day21"})

# ---------------------------------------------------------------- Hafta 7-9 · Büyü
add("w7-pzt", day(7, "pzt"), "20:30", "reel", "dönüşüm", f"""
#kareyo30 tamamlandı! 🎉 Gün 1 → Gün 30.

Boş bir saksıdan sarkan bir pothos'a. 30 gün, 30 kare, 10 saniye.

Sen de bitirdiysen filmini hikâyende paylaş, #kareyo30 ve @kareyo etiketle; en güzellerini burada paylaşacağız.

{tags("genel", "kareyo30", "bitki")}
""", {"template": "reel-sequence", "sequence": "pothos", "title": "Pothos", "frames": 30, "totalDays": 30, "music": "parlak"})

add("w7-car", day(7, "car"), "19:00", "carousel", "ipucu", f"""
Evcil hayvanının büyümesini çekmek zor mu? 🐾 4 taktik.

Yavru kedi ve köpekler hızlı büyür; 30 gün bile fark yaratır.

{tags("genel", "ipucu")} #evcilhayvan #yavrukedi #yavruköpek
""", {"template": "carousel", "accent": "gold", "slides": [
    {"kind": "cover", "eyebrow": "KATEGORİ · EVCİL HAYVAN", "title": "Dostunun\nbüyümesini\nyakala", "image": None},
    {"kind": "text", "n": 1, "title": "Sabit bir yer seç", "body": "Hep aynı minder ya da aynı köşe. Arka plan sabit kalınca büyüme belli olur."},
    {"kind": "text", "n": 2, "title": "Ödülle bekle", "body": "Mama kabının yanında ya da ödül maması elindeyken çek; birkaç saniye yerinde durur."},
    {"kind": "text", "n": 3, "title": "Bir ölçek koy", "body": "Yanına aynı oyuncağı ya da bir kutuyu koy. Büyüme ona göre göz önüne çıkar."},
    {"kind": "text", "n": 4, "title": "Mükemmeli bekleme", "body": "Hareket ettiyse de çek. Sihirli Hizalama sahneyi hizalar, kaçırma hakkın da var."},
    {"kind": "cta", "title": "Dostunun\nfilmi.", "body": "Kaydet 🔖"},
]})

add("w7-cum", day(7, "cum"), "19:00", "image", "ürün", f"""
Gizlilik varsayılan. 🔒

Kareyo'da fotoğrafların yalnızca telefonunda saklanır. Hizalama ve video üretimi tamamen cihazında yapılır. Birlikte Değiş'te bile ekibin yalnızca gün ve seri bilgisini görür; fotoğraf asla paylaşılmaz.

{tags("genel")} #gizlilik
""", {"template": "announce", "eyebrow": "GİZLİLİK", "headline": "Fotoğrafların\nsende kalır.", "body": "Hizalama ve video cihazında.\nBulut yok, reklam yok.", "screen": "detail", "accent": "mint"})

add("w8-pzt", day(8, "pzt"), "19:00", "carousel", "ipucu", f"""
Saç ve sakal değişimini çekmenin 4 kuralı. 🧔

Saç ve sakal günde milimetre büyür; açı ve ışık her gün aynı değilse fark kaybolur.

{tags("genel", "ipucu")} #sakal #saç #saçbakımı
""", {"template": "carousel", "accent": "coral", "slides": [
    {"kind": "cover", "eyebrow": "KATEGORİ · SAÇ / SAKAL", "title": "Milimetreyi\nfotoğrafla", "image": "sakal/day30"},
    {"kind": "text", "n": 1, "title": "Yüzün kameraya dik", "body": "Başını eğme, çeneni kaldırma. Telefon göz hizasında."},
    {"kind": "text", "n": 2, "title": "Canlı kılavuzu kullan", "body": "Kareyo kamerası dünkü yüzünün yerini kesikli çerçeveyle gösterir; oturunca 'Hizalandı' der."},
    {"kind": "text", "n": 3, "title": "Ön kamera mı arka mı?", "body": "Hangisiyle başladıysan onunla devam et. Lensler farklı görüntüler."},
    {"kind": "onion", "n": 4, "title": "Gün 1 ve Gün 30", "body": "Aynı kadraj, tek fark: sakal.", "sequence": "sakal", "a": 1, "b": 30, "aligned": False},
    {"kind": "cta", "title": "Bugün\nGün 1.", "body": "Kaydet 🔖"},
]})

add("w8-car", day(8, "car"), "20:30", "reel", "ürün", f"""
Sihirli Hizalama nasıl çalışır? 🪄

Solda ham kareler, sağda Kareyo'nun hizaladığı. Her gün telefon biraz kayar; Kareyo sahneyi bulup her kareyi aynı kadraja oturtur. Tamamen cihazında.

{tags("genel", "ipucu")}
""", {"template": "reel-compare", "music": "sakin", "left": "pilea", "right": "pilea-aligned", "leftLabel": "Ham", "rightLabel": "Sihirli Hizalama", "title": "Titreme yok."})

add("w8-cum", day(8, "cum"), "19:00", "image", "topluluk", f"""
Kiminle birlikte değişmek istersin? 🤝

Partnerin, kardeşin, spor arkadaşın… Kareyo'da Birlikte Değiş ile ekip kurun; ortak seriniz her gün ikinizin de çekmesiyle büyür.

Onu etiketle, bu hafta birlikte başlayın. 👇

{tags("genel")} #birliktedeğiş
""", {"template": "announce", "eyebrow": "BİRLİKTE DEĞİŞ", "headline": "Kiminle\nbaşlıyorsun?", "body": "Etiketle, ekibini kur.\nOrtak seri, iki kat motivasyon.", "screen": "circle", "accent": "coral"})

add("w9-pzt", day(9, "pzt"), "19:00", "carousel", "motivasyon", f"""
Alışkanlık kaç günde oluşur? 🧠

Popüler cevap 21 gün. Araştırmalar daha uzun ve kişiden kişiye değişen bir süre gösteriyor. İyi haber: önemli olan süre değil, her gün tekrar.

{tags("genel", "aliskanlik")}
""", {"template": "carousel", "accent": "gold", "slides": [
    {"kind": "cover", "eyebrow": "MOTİVASYON", "title": "Alışkanlık\nkaç günde\noluşur?", "image": "pilea/day15"},
    {"kind": "text", "n": 1, "title": "21 gün bir efsane", "body": "Sık duyulan '21 gün' kuralının sağlam bir dayanağı yok."},
    {"kind": "text", "n": 2, "title": "Araştırma ne diyor?", "body": "University College London'ın 2009 çalışmasında ortalama 66 gün çıktı; kişiye göre 18 ile 254 gün arası."},
    {"kind": "text", "n": 3, "title": "Bir günü kaçırmak sorun değil", "body": "Aynı çalışmaya göre arada bir günü kaçırmak alışkanlığın oluşmasını belirgin şekilde bozmadı."},
    {"kind": "text", "n": 4, "title": "Küçük ve hep aynı", "body": "Aynı saat, aynı bağlam, küçük bir eylem. Günde bir kare tam olarak bu."},
    {"kind": "cta", "title": "Bugün\nbir kare.", "body": "Kaydet 🔖"},
]})

add("w9-car", day(9, "car"), "20:30", "reel", "ürün", f"""
Tek dokunuşla Reels nasıl yapılır? 🎬

Değişimini aç → Videonu Oluştur → Hikâye. Kareyo kareleri hizalar, gün sayacını ve Önce/Sonra perdesini ekler. İstersen müzik seç; kareler vuruşa oturur.

{tags("genel")} #reels
""", {"template": "reel-product", "music": "hareketli", "scenes": [
    {"kind": "title", "eyebrow": "NASIL YAPILIR", "title": "Tek dokunuşla\nReels."},
    {"kind": "phone", "screen": "detail", "caption": "1 · Değişimini aç"},
    {"kind": "phone", "screen": "reveal", "caption": "2 · Hikâye'yi seç"},
    {"kind": "image", "image": "reel/lapse", "caption": "3 · Paylaş"},
    {"kind": "cta", "title": "Senin\nfilmin."},
]})

add("w9-cum", day(9, "cum"), "19:00", "image", "ipucu", f"""
Tek ihtiyacın: bir zamanlayıcı ve bir dayanak. ⏱️

Telefonu kitaplığa, rafa ya da bir bardağa daya; 10 saniyelik zamanlayıcıyı aç. Elin titremez, her gün aynı yükseklik.

{tags("genel", "ipucu")}
""", {"template": "quote", "quote": "Telefonu daya.\n10 saniye.\nÇek.", "accent": "mint", "image": "monstera/day30"})

# ---------------------------------------------------------------- Hafta 10-12 · Hızlan
add("w10-pzt", day(10, "pzt"), "20:30", "reel", "dönüşüm", f"""
3 bitki, 30 gün, aynı anda. 🌿🌱🪴

Fesleğen, monstera ve pilea; hepsi her gün bir kare. Hangisi en çok değişti?

{tags("genel", "bitki")}
""", {"template": "reel-triptych", "music": "parlak", "sequences": ["feslegen", "monstera", "pilea"], "labels": ["Fesleğen", "Monstera", "Pilea"], "title": "30 gün."})

add("w10-car", day(10, "car"), "19:00", "carousel", "ipucu", f"""
Değişim fotoğraflarında en sık yapılan 5 hata. 🚫

Kendini bunlardan birinde buldun mu? Yorumlara numarasını yaz.

{tags("genel", "ipucu")}
""", {"template": "carousel", "accent": "coral", "slides": [
    {"kind": "cover", "eyebrow": "İPUCU", "title": "En sık\n5 hata", "image": "pilea/day05"},
    {"kind": "text", "n": 1, "title": "Her gün farklı saat", "body": "Işık değişir, gölgeler kayar; değişim değil ışık görünür."},
    {"kind": "text", "n": 2, "title": "Zoom kullanmak", "body": "Yakınlaştırma her gün biraz farklı olur. Telefonu yaklaştır, zoom'u kullanma."},
    {"kind": "text", "n": 3, "title": "Filtre ve güzelleştirme", "body": "Filtre renkleri değiştirir. Değişimi değil filtreyi kaydedersin."},
    {"kind": "text", "n": 4, "title": "Kötü günü atlamak", "body": "Kötü gün de kayıttır. Atlamak seriyi bozar, kötü kare bozmaz."},
    {"kind": "text", "n": 5, "title": "Sonuca erken bakmak", "body": "Gün 5'te fark göremezsin. Gün 30'da göreceksin."},
    {"kind": "cta", "title": "Hepsinden\nkurtul.", "body": "Kaydet 🔖"},
]})

add("w10-cum", day(10, "cum"), "19:00", "image", "dönüşüm", f"""
Tohumdan tencereye: 30 günde fesleğen. 🌱→🌿

İlk 4 gün sadece toprak vardı. Sabır, her gün bir kare.

{tags("genel", "bitki")}
""", {"template": "beforeafter", "sequence": "feslegen", "left": 1, "right": 30, "headline": "Gün 1 → Gün 30"})

add("w11-pzt", day(11, "pzt"), "19:00", "carousel", "topluluk", f"""
Senin sorduğun, bizim yanıtladığımız: Kareyo SSS. 💬

Başka sorun varsa yorumlara yaz, bir sonraki SSS'ye ekleyelim.

{tags("genel")}
""", {"template": "carousel", "accent": "mint", "slides": [
    {"kind": "cover", "eyebrow": "SSS", "title": "En çok\nsorulanlar", "image": "monstera/day15"},
    {"kind": "text", "n": 1, "title": "Ücretli mi?", "body": "Kareyo ücretsiz. Premium; filigransız video, sayısal takip ve ekip kurma gibi ek özellikleri açar."},
    {"kind": "text", "n": 2, "title": "Fotoğraflarım nerede?", "body": "Yalnızca telefonunda. Kareyo fotoğraflarını bir sunucuya yüklemez."},
    {"kind": "text", "n": 3, "title": "Bir günü kaçırırsam?", "body": "Kaçırma hakkın o günü korur. İki gün üst üste kaçırılırsa değişim sona erer."},
    {"kind": "text", "n": 4, "title": "30 günden uzun olur mu?", "body": "Evet. Süreyi kendin seçersin ya da hedefe ulaşınca sınırsız devam edebilirsin."},
    {"kind": "cta", "title": "Sorun mu\nvar?", "body": "Yorumlara yaz 💬"},
]})

add("w11-car", day(11, "car"), "20:30", "reel", "dönüşüm", f"""
30 gün = 30 kare. 🧩 Tek tek bakınca küçük, birlikte bakınca dev bir fark.

Kareyo her günü bir kareye, 30 kareyi bir filme çevirir.

{tags("genel", "bitki")}
""", {"template": "reel-grid", "music": "sakin", "sequence": "monstera", "title": "30 gün = 30 kare"})

add("w11-cum", day(11, "cum"), "19:00", "image", "motivasyon", f"""
Bir yıl sonra bugünün karesine teşekkür edeceksin. 🙏

Değişimi en çok, başlangıcın fotoğrafını kaybetmiş olanlar özler. Bugün Gün 1'in olsun.

{tags("genel", "aliskanlik")}
""", {"template": "quote", "quote": "Bir yıl sonra\nbugünün karesine\nteşekkür edeceksin.", "accent": "gold", "image": "sakal/day01"})

add("w12-pzt", day(12, "pzt"), "19:00", "image", "dönüşüm", f"""
Monstera, 30 günün 30 karesi. 🌿

Her kare bir gün. Kaydır, gün gün izle; sonra kendi 30 gününü başlat.

{tags("genel", "bitki")}
""", {"template": "grid30", "sequence": "monstera", "headline": "30 gün", "body": "Monstera · her gün bir kare"})

add("w12-car", day(12, "car"), "20:30", "reel", "dönüşüm", f"""
12 haftada çektiğimiz her şey, tek videoda. 🎞️

Fesleğen, monstera, pilea, pothos ve 30 günlük sakal. Hepsi her gün bir kareyle başladı.

Sıradaki değişim senin. 👇

{tags("genel")}
""", {"template": "reel-montage", "music": "hareketli", "sequences": ["feslegen", "monstera", "pilea", "pothos", "sakal"], "title": "Her gün bir kare."})

add("w12-cum", day(12, "cum"), "19:00", "image", "topluluk", f"""
Sıradaki değişimin ne? 👇

12 hafta boyunca bitkiler büyüttük, sakal uzattık, #kareyo30'u bitirdik. Şimdi sıra sende: yorumlara başlayacağın değişimi yaz, 30 gün sonra burada görüşelim.

{tags("genel", "kareyo30")}
""", {"template": "announce", "eyebrow": "SIRA SENDE", "headline": "Sıradaki\ndeğişimin ne?", "body": "Yorumlara yaz,\n30 gün sonra görüşelim.", "screen": "home", "accent": "gold"})

# ---------------------------------------------------------------- Hikâyeler (haftada 3)
# API çıkartma (anket, link, soru) eklemiyor; hikâyeler "yanıtla" ve "profile git" çağrısıyla tasarlandı.
STORY_TIPS = [
    "Hatırlatma saatini her gün çektiğin saate kur.",
    "Dünkü kare hayalet katmanda: çizgileri eşle, çek.",
    "Zoom kullanma; telefonu yaklaştır.",
    "Filtre yok. Değişimi kaydet, filtreyi değil.",
    "Kötü gün de kayıttır. Atlama, çek.",
    "Zamanlayıcıyı aç, telefonu daya.",
    "Pencereye yüzünü dön, sırtını değil.",
    "Hep aynı kamera: ön ya da arka.",
    "Saksıyı her gün aynı yöne çevir.",
    "Sabah, kahvaltıdan önce: en tutarlı saat.",
    "Ekip kur: ortak seri, iki kat motivasyon.",
    "Gün 30'da Reels'ini paylaş, #kareyo30 etiketle.",
]
for w in range(1, 13):
    first_feed = next(i for i in items if i["day"] >= day(w, "pzt") and i["kind"] != "story")
    add(f"s{w}-pzt", day(w, "pzt"), "21:30", "story", "topluluk", "",
        {"template": "story-newpost", "post": first_feed["id"]})
    add(f"s{w}-car", day(w, "car"), "09:30", "story", "topluluk", "",
        {"template": "story-question", "headline": "Bugünün karesini\nçektin mi?", "options": ["📸 Çektim", "⏳ Akşam çekeceğim"], "footer": "Yanıtla, bize yaz 💬"})
    if 3 <= w <= 7:
        streak_day = {3: 3, 4: 10, 5: 17, 6: 24, 7: 30}[w]
        add(f"s{w}-cmt", day(w, "cmt"), "12:00", "story", "topluluk", "",
            {"template": "story-streak", "sequence": "pothos", "frame": streak_day, "headline": f"#kareyo30 · Gün {streak_day}"})
    else:
        add(f"s{w}-cmt", day(w, "cmt"), "12:00", "story", "ipucu", "",
            {"template": "story-tip", "n": w, "tip": STORY_TIPS[w - 1]})

items.sort(key=lambda i: (i["day"], i["time"]))
for i in items:
    assert len(i["caption"]) <= 2200, i["id"]
    assert i["caption"].count("#") <= 30, i["id"]
os.makedirs(os.path.join(ROOT, "content"), exist_ok=True)
with open(os.path.join(ROOT, "content", "plan.json"), "w") as f:
    json.dump({"version": 1, "items": items}, f, ensure_ascii=False, indent=2)
kinds = {}
for i in items:
    kinds[i["kind"]] = kinds.get(i["kind"], 0) + 1
print(len(items), "öğe", kinds, "son gün", max(i["day"] for i in items))
