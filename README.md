# Kareyo Instagram · otomatik paylaşım

12 haftalık içerik (47 akış gönderisi, 36 hikâye) ve bunları zamanında paylaşan otomasyon.
Takvim: [TAKVIM.md](TAKVIM.md).

## Nasıl çalışır

- `content/plan.json`: her gönderinin günü, saati, türü ve açıklaması (kaynağı `tools/plan.py`).
- `content/media/<id>/`: gönderinin görselleri (`01.jpg`…) ya da `reel.mp4` + `cover.jpg`.
- `.github/workflows/post.yml`: GitHub Actions **her 30 dakikada** bir çalışır; zamanı gelen
  gönderileri Instagram API ile paylaşır ve `state/posted.json`a yazar. Bilgisayarın kapalı
  olsa da çalışır.
- Instagram medyayı herkese açık bir adresten çeker; adres bu deponun GitHub Pages sitesidir
  (`config.json` → `media_base_url`).
- `.github/workflows/refresh-token.yml`: Instagram anahtarını haftada bir yeniler (60 günde
  dolmasın diye).

## Kurulum (bir kerelik, senin yapman gereken kısım)

1. **Instagram hesabı** → Ayarlar → Hesap türü → *Profesyonel hesap* (İşletme ya da İçerik
   Üretici). Profil fotoğrafı, biyografi ve App Store bağlantısını elle ekle.
2. **Meta uygulaması**: [developers.facebook.com](https://developers.facebook.com) → *Uygulama
   oluştur* → kullanım durumu olarak *Instagram API'si* (Instagram ile giriş). *API setup with
   Instagram login* bölümünde Instagram hesabını ekle ve **Generate token** ile anahtar üret
   (izinler: `instagram_business_basic`, `instagram_business_content_publish`).
   Uygulama geliştirme modunda kalabilir; kendi hesabına paylaşım için uygulama incelemesi
   gerekmez. Ekranda görünen **Instagram kullanıcı kimliğini** (ID) de not al.
3. **GitHub deposu** (ben oluşturup yükleyeceğim) → *Settings*:
   - *Pages*: Source = `Deploy from a branch`, Branch = `main` / `(root)`.
   - *Secrets and variables → Actions* → üç sır:
     - `IG_USER_ID`: 2. adımdaki kullanıcı kimliği
     - `IG_ACCESS_TOKEN`: 2. adımdaki anahtar
     - `GH_PAT`: [ince ayarlı kişisel erişim anahtarı](https://github.com/settings/personal-access-tokens/new);
       yalnızca bu depo, izin: *Secrets → Read and write* (anahtar yenileme için).
4. **Başlangıç tarihi**: `config.json` → `"start_date": "2026-11-22"` gibi **bir Pazar**. O gün
   10:00'dan itibaren 9 gönderilik başlangıç ızgarası paylaşılır, pazartesi 1. hafta başlar.
   1. haftanın gönderileri Kareyo 1.2'yi anlatıyor; tarihi 1.2 App Store'a çıktıktan sonraya koy.

## Günlük kullanım

- **Durdur**: `config.json` → `"paused": true`.
- **Tek gönderiyi hemen paylaş**: Actions → *Instagram paylaşımı* → *Run workflow* → `only` = id.
- **Ne zaman ne paylaşılacak**: `python3 tools/post.py --list`
- **Denemek (paylaşmadan)**: `python3 tools/post.py --dry-run --now 2026-11-24T19:05`
- Bir paylaşım başarısız olursa GitHub e-postayla bildirir; gönderi bir sonraki çalıştırmada
  tekrar denenir. 24 saatten eski hikâyeler atlanır; gecikmiş akış gönderileri birer birer
  paylaşılır.

## Otomasyonun yapamadıkları (elle)

Instagram API'si bunları desteklemiyor:
- Hikâye çıkartmaları (anket, soru, bağlantı). Hikâyeler "yanıtla" çağrısıyla tasarlandı.
  Paylaşılmış bir hikâyeye sonradan çıkartma eklenemiyor; çıkartma istediğin günlerde
  (ör. #kareyo30 başlangıcı) aynı görseli uygulamadan elle de paylaşabilirsin.
- Öne çıkan hikâyeler (Highlights), profil düzeni, yorum/DM yanıtları.
- Instagram'ın müzik kütüphanesi: reels'lerdeki müzik bizim ürettiğimiz telifsiz parçalar.
- Hafta 7-9 iş birlikleri (Collab gönderileri), kullanıcı paylaşımlarını yeniden paylaşma,
  Hafta 10-12 reklam bütçesi.

## İçeriği yeniden üretmek

`tools/build.sh` her şeyi yeniden üretir (macOS + Xcode araçları gerekir):
plan → müzik → reels → görseller → denetim (`tools/check.py`).
Bitki/sakal dizileri `tools/scenes.swift` ile çizildi (gerçek fotoğraf değil). "reel-sequence"
türündeki reels'ler uygulamanın kendi Reels motoruyla (simülatörde) üretilip
`content/build/raw-reels/` içine konuyor.
