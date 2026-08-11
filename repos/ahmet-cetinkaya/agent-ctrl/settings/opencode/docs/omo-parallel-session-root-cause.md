# OpenCode paralel session sorunu — kök neden bulundu: OMO runtime fallback

**Tarih:** 2026-08-01 → 2026-08-02
**Durum:** Kök neden doğrulandı, kalıcı çözüm kararı bekliyor (bkz. Sonuç/Öneriler)

## Belirti

İki OpenCode oturumu aynı anda açılıp aynı prompt verildiğinde:
- Bir oturum çalışmaya başlarken diğeri sürekli `"Structurally heavy chat request
  capacity is busy; retry shortly."` hatası vermeye başlıyor.
- Bir süre sonra ilk oturum `interrupted` oluyor ("Released wakelock (session error)").
- İkinci oturum daha sonra çalışmaya başlayıp tamamlanıyor.
- Yani **tek seferde sadece bir oturum gerçekten ilerleyebiliyor**; ikinci oturum
  birinciyi bloke ediyor veya birbirlerini timeout/retry fırtınasına sokuyorlar.

Kullanıcı gözlemi: bu sorun, OMO konfigürasyonunda modellere **açık fallback
zincirleri** tanımlandıktan sonra başladı — bu doğru bir teşhis oldu.

## Araştırma zinciri

### 1. Upstream mi, client-side mi?

Aynı OmniRoute kurulumu, aynı combo'lar, aynı Claude hesapları paylaşılarak
**Claude Code** ile karşılaştırma testi yapıldı (Claude Code de OmniRoute üzerinden
aynı upstream'i kullanıyor). Claude Code'da 2 session × 3 paralel subagent sorunsuz
tamamlandı (Playwright ile doğrulandı: labirent.html, index.html üretildi).

**Sonuç:** Aynı upstream/Claude hesapları ile OpenCode+OMO'da başarısız olan aynı
iş yükü, Claude Code'da (OMO'suz) sorunsuz çalıştı → **darboğaz upstream/Claude
kapasitesinde değil, client-side (OpenCode/OMO) tarafında.**

### 2. OMO runtime_fallback mekanizması incelendi

`oh-my-openagent` dist kodunda (`dist/index.js`) doğrulandı:
- `runtime_fallback.timeout_seconds` (>0 iken) **sağlıklı çalışan** bir isteği
  bile timeout ile abort edip fallback modele geçiyor → bu abort event'i
  `interrupted` olarak görünüyor.
- Hata alındığında client aynı/başka modele retry yaptığında, iki paralel
  session'ın retry'ları üst üste binerek upstream admission'ı dolduruyor
  ("Structurally heavy chat request capacity is busy" bu admission-storm'un
  belirtisi).
- `omniroute/auto/best-free` gibi OMO fallback zincirinin son hedefi OmniRoute'ta
  **hiç tanımlı değildi** — yani OMO'nun kendi fallback zinciri zaten kırıktı.

### 3. Ara çözüm denemesi — fallback'i OmniRoute'a taşı

Fallback sorumluluğu client'tan (OMO) sunucuya (OmniRoute) taşındı:
- OmniRoute'ta her OMO agent/category için tek bir `combo/omo_<ad>` (17 adet,
  `strategy:"priority"`, sıralı hedef zinciri) oluşturuldu.
- `omo.jsonc`'de her agent/category tek bir `omniroute/combo/omo_<ad>` modeline
  yönlendirildi, `fallback_models` dizileri kaldırıldı.
- `runtime_fallback.enabled` → `false`.

**Sonuç:** `interrupted` durumu ortadan kalktı (server-side fallback devreye
girdi — opus 429 → glm, zai 429/529 → kiro-haiku gibi). Ancak paralel
session'larda hâlâ bir session'ın ilerlerken diğerinin beklediği/geciktiği
gözlemlendi (bkz. ekran görüntüleri 2026-08-02 09:59, 10:02 vb.) — yani
`runtime_fallback.enabled: false` sorunu **azalttı ama tam çözmedi**.

### 4. Kesin izolasyon testi — vanilla OpenCode (OMO'suz)

Tüm OpenCode state/config/cache dizinleri yeniden adlandırılarak (rename)
yedeklendi ve tamamen vanilla bir kuruluma dönüldü:

| Dizin | Yedek |
|---|---|
| `~/.config/opencode` | `.bak-2026-08-02` |
| `~/.local/share/opencode` | `.bak-2026-08-02` |
| `~/.local/state/opencode` | `.bak-2026-08-02` |
| `~/.cache/opencode` | `.bak-2026-08-02` |

(OpenCode kurulum yöntemi doğrulandı: standalone binary `~/.opencode/bin/opencode`,
PATH'e `~/.zshrc:26` ile eklenmiş, **Nix ile yönetilmiyor** — bu yüzden dizin
rename'i güvenli ve yeterli bir sıfırlama yöntemi.)

**Adım A — OMO'suz, OpenCode Zen (dahili ücretsiz model):**
İki session paralel başlatıldı, ikisi de `MiMo V2.5 Free` (OpenCode Zen) kullandı.
Paralel çalıştı, sorun yok. Ama iki değişken birden değişmişti (OMO yok +
farklı upstream) — kesin teşhis için yetersiz.

**Adım B — OMO'suz, ama OmniRoute'a bağlı (izolasyon testi):**
Sadece `opencode-omniroute-auth` plugin'i (OMO **değil**) eklendi:

```jsonc
// ~/.config/opencode/opencode.jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-omniroute-auth"],
  "provider": {
    "omniroute": {
      "options": { "baseURL": "http://192.168.1.4:8208/v1" }
    }
  }
}
```

`/connect omniroute` ile API key girildi, model `combo/omo_sisyphus` (aynı
OmniRoute combo, aynı Claude/GLM fallback zinciri, aynı upstream hesaplar)
seçildi. İki session paralel başlatıldı, aynı prompt verildi.

**Sonuç: İkisi de sorunsuz, birbirini bloklamadan aynı anda tamamlandı.**
Hiçbir `interrupted`, hiçbir "capacity is busy" hatası, hiçbir bekleme
gözlemlenmedi.

## Kök neden (doğrulandı)

| Değişken | Bozuk durum | Çalışan durum (izolasyon testi) |
|---|---|---|
| Plugin | OMO (`oh-my-openagent`) | `opencode-omniroute-auth` (OMO yok) |
| Model | `combo/omo_sisyphus` | `combo/omo_sisyphus` (aynı) |
| Upstream | OmniRoute → Claude/GLM | OmniRoute → Claude/GLM (aynı) |
| Sonuç | 1 session ilerlerken diğeri bekliyor/interrupted | ikisi de paralel, sorunsuz |

Tek değişen faktör OMO plugin'in varlığı/yokluğu olduğu için, **kök neden OMO'nun
kendisi** — spesifik olarak:
- `runtime_fallback` mekanizmasının timeout/abort davranışı (kısmen `enabled:
  false` ile azaltıldı), ve/veya
- OMO'nun subagent fan-out / retry katmanının, paralel session'lar arasında
  upstream admission'ı paylaşırken yarattığı ek yük.

OmniRoute/upstream Claude kapasitesi hiçbir zaman gerçek darboğaz değildi.

## Sonuç / Öneriler

İki seçenek var, kullanıcı kararı bekliyor:

1. **OMO'suz kalıcı setup** — `opencode-omniroute-auth` + doğrudan OmniRoute
   combo'ları. Stabil ama OMO'nun agent/category/skill katmanından (Sisyphus,
   Hephaestus, Oracle vb. isimlendirilmiş agent profilleri, background_task
   concurrency limiti gibi) vazgeçilmiş olur.
2. **OMO ile devam** — `runtime_fallback.enabled: false` + tek-combo mapping
   (zaten uygulanmış durumda) korunarak, bu izolasyon testinin OMO'lu hâli
   tekrarlanıp gerçekten çözülüp çözülmediği doğrulanır. Hâlâ sorun varsa OMO'nun
   subagent fan-out katmanı (`background_task.defaultConcurrency`) veya başka
   bir iç mekanizma incelenmeli.

## İlgili dosyalar

- `~/.omo/omo.jsonc` (aktif config, yedek: `omo.jsonc.bak-2026-07-31`)
- `~/.claude/settings.json` (Claude Code mirror — sisyphus/atlas/explore combo'ları)
- `settings/opencode/docs/model-matrix-implementation-notes.md` (önceki ilgili
  root-cause: model ID uyuşmazlığı — ayrı bir sorun, bu belgeyle karıştırılmamalı)
- `~/Configs/.debug-journal.md` (2026-07-29 tarihli önceki OMO model-ID root
  cause analizi — bu dokümanın konusu değil, ama aynı OMO/OpenCode entegrasyon
  yüzeyi)
