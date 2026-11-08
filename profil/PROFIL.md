# Instagram profil kurulumu (elle, bir kerelik)

Paylaşım otomatik; profil ayarlarını Instagram API'si değiştiremediği için bunlar elle yapılır.
Gün 0'dan (başlangıç ızgarası) **önce** bitmiş olmalı.

## Hesap

- **Kullanıcı adı** (öncelik sırası): `kareyo` → `kareyo.app` → `kareyoapp`
- **Hesap türü**: Profesyonel → İşletme, kategori *Uygulama Sayfası*
- **Ad**: `Kareyo · Her gün bir kare`
- **Profil fotoğrafı**: `profil-fotografi.jpg` (uygulama ikonu; Instagram daire olarak kırpar)

## Biyografi (kopyala-yapıştır)

```
Günlük fotoğrafını çek, değişimini timelapse'te izle.
Kilo · bitki · evcil hayvan · saç/sakal
Fotoğrafların yalnızca telefonunda 🔒
↓ iOS'ta ücretsiz
```

## Bağlantı

```
https://apps.apple.com/tr/app/kareyo/id6809846718
```

Instagram'dan gelen indirmeleri ayrı görmek için App Store Connect → *Uygulama Analizi* →
*Kampanyalar* bölümünden bu bağlantıya `instagram-bio` adlı bir kampanya bağlantısı üret ve
yukarıdakinin yerine onu koy.

## Öne çıkan hikâyeler (Highlights)

Kapaklar bu klasörde (`one-cikan-*.jpg`). Öne çıkanlara yalnızca hikâyeler eklenebilir; bir
gönderiyi eklemek için önce onu gönderinin altındaki ✈︎ → *Hikâyene ekle* ile paylaş. Sonra
profilde **+ Yeni** → hikâyeleri seç → kapak olarak bu görseli yükle.

| Sıra | Ad | Kapak | İçine eklenecekler |
|---|---|---|---|
| 1 | Nasıl? | one-cikan-1-nasil | "Kareyo nasıl çalışır" (Gün 0, kaydırmalı) ve "Hayalet katman" (Hafta 1 Paz) gönderilerini hikâyede paylaş |
| 2 | Önce/Sonra | one-cikan-2-once-sonra | Gün 0 ve Hafta 2 Paz Önce/Sonra gönderileri, sonra kullanıcı paylaşımları (izinle) |
| 3 | Widget | one-cikan-3-widget | "Gün bitmeden hatırlatır" reel'ini (Gün 0) hikâyede paylaş |
| 4 | #kareyo30 | one-cikan-4-kareyo30 | Hafta 3-7 cumartesi "seri kontrolü" hikâyeleri |
| 5 | Yenilikler | one-cikan-5-yenilikler | Hafta 1 pazartesi "Yeni gönderi" hikâyesi (otomatik gelir) ve sonraki sürümler |

## Gün 0 kontrol listesi

- [ ] Profil fotoğrafı, ad, biyografi, bağlantı
- [ ] Hesap profesyonel; Meta uygulaması ve anahtar hazır (README → Kurulum)
- [ ] GitHub sırları girildi, Pages açık
- [ ] `config.json` → `start_date` = Gün 0 (bir Pazar, 1.2 App Store'da yayında)
- [ ] Gün 0 saat 10:00-10:40 arası 9 gönderi otomatik gelecek; 11:00'de profili kontrol et
