# Takım Görevleri

Küçük bir proje ve görev takip uygulaması. Kullanıcı kayıt olur, proje açar, projeye görev ekler, görevleri tamamlar ve tamamlananları temizler. Yöneticiler tüm projeleri listeleyebilir.

## Yapı

| Dosya | Görevi |
|---|---|
| `index.html` | Arayüz (tek sayfa, Supabase JS istemcisi) |
| `supabase/migrations/20261111000000_init.sql` | Tablolar, profil tetikleyicisi, erişim kuralları |
| `supabase/functions/get-project/index.ts` | Proje ve görevlerini döndüren sunucu fonksiyonu |
| `supabase/config.toml` | Fonksiyon ayarı |

## Beklenen kurallar

- Her kullanıcı yalnızca kendi projelerini ve o projelerin görevlerini görür ve değiştirir.
- Kullanıcı profilinde yalnızca kendi görünen adını değiştirebilir.
- Proje sayfasındaki "Tamamlananları temizle" yalnızca o projedeki tamamlanmış görevleri siler; kullanıcının diğer projelerine dokunmaz.
- Yönetici rolü kullanıcıya elle atanır; yöneticiler tüm projeleri listeleyebilir.

## Kurulum

1. Boş bir Supabase projesi aç. Bu bir demo uygulamadır; içine gerçek veri koyma.
2. SQL Editor'da `supabase/migrations/20261111000000_init.sql` dosyasını çalıştır.
3. Fonksiyonu yayınla: `supabase functions deploy get-project`
4. `index.html` içindeki `SUPABASE_URL` ve `SUPABASE_ANON_KEY` değerlerini kendi projenin bilgileriyle değiştir.
5. `index.html` dosyasını tarayıcıda aç ya da herhangi bir statik barındırmaya yükle.
