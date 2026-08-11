# OmniRoute + OpenCode paralel ağır istek sorunu

**Tarih:** 2026-08-01 → 2026-08-02  
**Durum:** ÇÖZÜLDÜ — kök neden OmniRoute'un varsayılan process-wide ağır-istek admission
limiti (`OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=1`) olarak doğrulandı. `2`'ye çıkarılıp
OmniRoute yeniden başlatıldıktan sonra iki paralel OpenCode + OMO session'ı, alt
ajanları dahil, hatasız tamamlandı (bkz. "Doğrulama — düzeltme uygulandı" bölümü).  
**İlgili önceki belge:** `omo-parallel-session-root-cause.md` — ilk hipotezleri kaydeder; bu belge sonraki karşılaştırmalı testlerle ulaşılan güncel sonucu esas alır.

## Yönetici özeti

İki OpenCode oturumu aynı anda OMO'nun `Sisyphus - ultraworker` agent'ıyla aynı ağır promptu çalıştırdığında, OmniRoute üzerinden yapılan ikinci istek sıklıkla şu hataya giriyor:

```text
Structurally heavy chat request capacity is busy; retry shortly.
```

OpenCode daha sonra yaklaşık saniyede bir yeniden deniyor:

```text
[retrying attempt #27]
```

Karşılaştırmalı testler sorunu yalnız OMO'ya, yalnız Claude'a veya yalnız belirli bir model combo'suna bağlamayı çürüttü:

- OMO olmadan OpenCode + OmniRoute paralel çalışabildi.
- OMO ile doğrudan OpenAI OAuth üzerinden iki paralel GPT-5.6 Sol isteği çalışabildi.
- OMO ile OmniRoute üzerinden hem Claude Opus 5 hem Codex GPT-5.6 Sol başarısız oldu.
- OMO ile OmniRoute combo kullanıldığında da aynı sorun oluştu; sonraki combo hedefleri çalışmaya başlamasına rağmen OpenCode isteği abort ettiği için OmniRoute kayıtlarında `499` görüldü.
- OMO 4.19.1 ve 4.19.4 aynı davranışı gösterdi.

Bu nedenle güncel sonuç şudur:

> Sorun OMO'nun genel paralellik desteği değildir. Sorun, OMO'nun ağır Sisyphus/ultraworker isteği ile OpenCode'un AI SDK retry davranışının **OmniRoute yolu üzerinden** etkileşiminde ortaya çıkmaktadır. Kesin sahiplik OmniRoute çekirdeği, OmniRoute'un upstream OAuth/relay bağlantısı veya bu iki katmanın hata/stream sınıflandırması arasında ayrıştırılmalıdır.

## Belirti

İki ayrı dizinde iki OpenCode süreci açıldı:

```text
~/Downloads/opencode-test-1.4
~/Downloads/opencode-test-2.4
```

Her ikisine aynı prompt verildi:

```text
Bana bir tek yeni bir html dosyasında noktayı mouse ile hareket ettirerek
labirentten çıkartma oyunu yapmanı istiyorum. Kenarlara çarptığında yeniden
başlamalı, her başlamada labirent değişmelidir. Bu görevi mümkün olduğunca alt
ajanlarla çalışacak detaylı gerçekleştir.
```

Tipik davranış:

1. İlk session model stream'ini alır ve ilerler.
2. İkinci session aynı modele/route'a başlar.
3. İkinci session `Structurally heavy chat request capacity is busy` alır.
4. OpenCode AI SDK yaklaşık 1 saniyelik aralıklarla isteği yeniden başlatır.
5. Önceki istekler client tarafından abort edilir; OmniRoute log'larında `499` oluşabilir.
6. İlk session tamamlanınca veya kapasite serbest kalınca ikinci session ilerleyebilir.

## Test matrisi

| Test | OMO | Bağlantı yolu | Model | Sonuç |
|---|---:|---|---|---|
| Vanilla OpenCode | Hayır | OpenCode Zen | MiMo V2.5 Free | İki session paralel çalıştı |
| Vanilla OpenCode | Hayır | OmniRoute (`opencode-omniroute-auth`) | `combo/omo_sisyphus` | İki session paralel tamamlandı |
| OMO 4.19.1 | Evet | Doğrudan OpenAI OAuth | `openai/gpt-5.6-sol` | İki Sisyphus session paralel çalıştı; yeni stream error yok |
| OMO 4.19.1 | Evet | OmniRoute | `claude/claude-opus-5` | İkinci session retry storm'a girdi |
| OMO 4.19.1 | Evet | OmniRoute | `codex/gpt-5.6-sol` | İkinci session retry storm'a girdi |
| OMO 4.19.1 | Evet | OmniRoute combo | `combo/omo_sisyphus` | İkinci session retry storm; fallback denemeleri `499` ile abort edildi |
| OMO 4.19.4 | Evet | OmniRoute | Claude/combo yolları | Aynı temel belirti |

### Matrisin anlamı

Bu sonuçlar aşağıdaki basit açıklamaları eler:

- **“OpenCode paralel session desteklemiyor.”** Yanlış; vanilla ve doğrudan OpenAI testleri paralel çalıştı.
- **“OMO genel olarak paralelliği bozuyor.”** Yanlış; OMO + doğrudan OpenAI OAuth paralel çalıştı.
- **“Sadece Claude ağır-chat admission limiti.”** Eksik; OmniRoute üzerinden Codex GPT-5.6 Sol da aynı hata metnini üretti.
- **“Yalnız OMO 4.19.4 regresyonu.”** Yanlış; 4.19.1'de de tekrarlandı.
- **“Combo fallback çözer.”** Yanlış; client ilk hata sonrası isteği abort ederse combo'nun sonraki hedefi tamamlanamıyor.

En dar güvenilir sonuç:

```text
OMO ağır istek/payload + OpenCode AI SDK + OmniRoute route/relay/stream davranışı
```

birlikteliği sorunu tetikliyor.

## Log kanıtları

### 1. Aynı anda iki Claude Opus 5 session

OpenCode log yolu:

```text
~/.local/share/opencode/log/opencode.log
```

Session 1.4:

```text
timestamp=2026-08-02T09:11:31.914Z
run=62fccdbd
providerID=omniroute
modelID=claude/claude-opus-5
agent="Sisyphus - ultraworker"
message=stream
```

Bu run temiz ilerledi; `stream error` almadı.

Session 2.4:

```text
timestamp=2026-08-02T09:11:32.461Z
run=ca9d885e
providerID=omniroute
modelID=claude/claude-opus-5
agent="Sisyphus - ultraworker"
error.error="AI_APICallError: Structurally heavy chat request capacity is busy; retry shortly."
```

Aynı session yaklaşık 30 saniyede 30 `stream error` üretti:

```text
session.id=ses_03e41dbbaffeRHyXt3sYVEhlCw
stream error count=30
ilk hata=2026-08-02T09:11:32.461Z
son hata=2026-08-02T09:12:02.645Z
```

Aralık yaklaşık 1 saniyedir. Her denemede log şunu gösterdi:

```text
llm.runtime=ai-sdk
llm.provider=omniroute
llm.model=claude/claude-opus-5
```

Bu retry göstergesi OMO'nun `runtime_fallback` mekanizmasından değil, OpenCode'un model çağrı/AI SDK katmanından gelir.

### 2. OMO runtime fallback kapalıydı

Taze OMO config'inde `runtime_fallback` alanı yoktu. Kurulu OMO runtime kodu varsayılanı açıkça `false` olarak hesaplıyordu:

```text
pluginConfig.runtime_fallback?.enabled ?? false
```

Dolayısıyla bu testlerdeki saniyelik retry döngüsü OMO `runtime_fallback` tarafından üretilmedi.

### 3. OmniRoute combo fallback çağrıları client tarafından abort edildi

`combo/omo_sisyphus` testinde OmniRoute yalnız Claude'u denemedi; Codex ve GLM hedeflerine de geçti. Ancak OpenCode yeni retry başlatırken önceki HTTP isteğini kesti.

OmniRoute call-log örnekleri:

```text
requestedModel=codex/gpt-5.6-sol
status=499
error="Client disconnected: request_signal_aborted"
```

ve:

```text
requestedModel=glm-5
provider=kiro
status=499
error="Request aborted"
```

Üst combo kaydı da `499` oldu. Bu, server-side fallback'in seçilmediğini değil, seçilen fallback'in client abort'u nedeniyle tamamlanamadığını gösterir.

### 4. OmniRoute üzerinden Codex GPT-5.6 Sol da aynı hatayı aldı

İki session doğrudan OmniRoute model ID'sini kullandı:

```text
omniroute/codex/gpt-5.6-sol
```

İlk session ilerledi; ikinci session:

```text
providerID=omniroute
modelID=codex/gpt-5.6-sol
error.error="AI_APICallError: Structurally heavy chat request capacity is busy; retry shortly."
```

aldı. Bu bulgu hata metninin yalnız Claude model kapasitesine özgü kabul edilemeyeceğini gösterir.

Aynı test penceresindeki OmniRoute call log'ları hem başarılı hem abort edilmiş Codex çağrıları içerir:

```text
status=200
requestedModel=codex/gpt-5.6-sol
provider=codex
```

ve:

```text
status=499
requestedModel=codex/gpt-5.6-sol
error="Request aborted"
```

Bu durum upstream modelin tamamen kullanılamaz olmadığını; ikinci OpenCode akışının admission/retry/abort etkileşimine girdiğini gösterir.

### 5. Doğrudan OpenAI OAuth karşı testi başarılıydı

Aynı OMO 4.19.1, aynı `Sisyphus - ultraworker`, aynı prompt; yalnız bağlantı yolu değiştirildi:

```text
providerID=openai
modelID=gpt-5.6-sol
```

İki session yaklaşık aynı anda başladı:

```text
2026-08-02T09:44:03.071Z  session 1
2026-08-02T09:44:03.530Z  session 2
```

İkisinin de non-small model stream'i başladı ve bu test penceresinde yeni `stream error` oluşmadı. Böylece OMO'nun ağır promptu ve GPT-5.6 Sol tek başına sorun olmaktan çıktı; fark OmniRoute yoluydu.

## Sürüm testleri

### OMO 4.19.4

- Resmi installer kullanıldı.
- Reasoning-unification değişikliği nedeniyle config migration/schema tutarsızlığı görüldü.
- Paralel heavy request sorunu devam etti.

### OMO 4.19.1

Plugin şu şekilde sabitlendi:

```json
"oh-my-openagent@4.19.1"
```

Tüm OpenCode/Bun module cache'leri temizlendi ve paket yeniden kuruldu. Doctor sonucu:

```text
✓ System OK (opencode 1.18.11 · oh-my-openagent 4.19.1)
```

Paralel OmniRoute testinde sorun yine oluştu. Dolayısıyla heavy request problemi 4.19.4 reasoning-unification regresyonuna indirgenemez.

Daha sonra plugin tekrar `oh-my-openagent@latest` olarak ayarlandı ve module cache'leri yeniden temizlendi.

## Config/schema yan bulgusu

OMO 4.19.4 installer canonical `agents.*.models` dizileri üretebiliyor; fakat aynı sürümün `AgentOverrideConfigSchema` tanımı yalnız şunları kabul ediyordu:

```text
model
fallback_models
```

Doctor ise `fallback_models` için `models` kullanılmasını öneriyordu. Bu upstream tutarsızlığı ayrı bir açık issue ile eşleşti:

- https://github.com/code-yeongyu/oh-my-openagent/issues/6515

Bu schema/migration sorunu heavy request incident'inin ana kök nedeni değildir; yalnız test kurulumunu etkileyen bağımsız bir yan bulgudur.

## Güncel kök neden değerlendirmesi

### Doğrulanmış

1. Paralellik genel olarak OpenCode'da çalışıyor.
2. OMO ile paralellik doğrudan OpenAI OAuth yolunda çalışıyor.
3. OmniRoute üzerinden OMO ağır istekleri paralel çalıştırıldığında ikinci istek admission/retry döngüsüne girebiliyor.
4. Hata Claude'a özgü değil; OmniRoute Codex rotasında da tekrarlandı.
5. OpenCode AI SDK retry sırasında önceki HTTP çağrısını abort ediyor.
6. Abort, OmniRoute fallback hedeflerinin `499` ile yarıda kalmasına yol açıyor.
7. OMO `runtime_fallback` bu testlerde kapalıydı ve saniyelik retry'nin kaynağı değildi.
8. OMO 4.19.1 ve 4.19.4 aynı incident sınıfını gösterdi.

### Henüz kesinleşmemiş

Aşağıdaki alt katmanlardan hangisinin ilk `Structurally heavy...` hatasını ürettiği kesin değildir:

1. OmniRoute çekirdeğinin request admission/queue katmanı.
2. OmniRoute'un kullandığı upstream OAuth/relay gateway'i.
3. Connection/account seçim katmanındaki ortak semaphore veya concurrency anahtarı.
4. Stream başlamadan/başladıktan sonra error classification ve response commit davranışı.

Bu nedenle “OmniRoute çekirdeği kesin bozuk” demek için henüz kod trace'i gerekir. Güvenli ifade:

> Hata OmniRoute yolu kullanıldığında ortaya çıkıyor ve doğrudan provider yolunda kayboluyor; sorun OmniRoute'un kendisi veya kullandığı upstream relay ile OpenCode retry/abort etkileşimi içinde yer alıyor.

## Muhtemel teknik akış

```text
OpenCode session A
  └─ Sisyphus heavy request ───────────────┐
                                           ├─ OmniRoute /v1/messages
OpenCode session B                         │
  └─ Sisyphus heavy request ───────────────┘
                                              │
                                              ├─ A kabul edilir / stream başlar
                                              └─ B heavy admission hatası alır
                                                   │
                                                   └─ OpenCode AI SDK retry
                                                        │
                                                        ├─ önceki request abort
                                                        ├─ OmniRoute 499
                                                        └─ yaklaşık 1 sn sonra yeni request
```

Combo kullanılırsa:

```text
Claude hedefi hata
  └─ OmniRoute Codex/GLM fallback başlatır
       └─ OpenCode ilk hata/retry nedeniyle request'i abort eder
            └─ çalışan fallback 499 olur
```

## İncelenmesi gereken OmniRoute akışı

OmniRoute repo'sunda aşağıdaki akış uçtan uca trace edilmelidir:

```text
/v1/messages
  → request admission / queue
  → provider/connection/account selection
  → per-connection concurrency limiter
  → upstream OAuth/relay request
  → streaming error detection
  → retryable error classification
  → combo fallback
  → response stream commit
  → client abort propagation
```

### Aranacak sinyaller

```text
Structurally heavy chat request capacity is busy
Chat admission capacity is temporarily unavailable
request_signal_aborted
Client disconnected
Request aborted
status=499
```

### Sorulacak sorular

1. Heavy-chat admission anahtarı global mi, API key bazlı mı, provider/account/connection bazlı mı?
2. İki farklı OpenCode process'i aynı API key ile geldiğinde ortak bir active-request reservation kullanılıyor mu?
3. Codex rotasında neden Claude'a benzeyen `Structurally heavy...` hata metni görülüyor?
4. Hata upstream relay'den mi geliyor, yoksa OmniRoute tarafından normalize mi ediliyor?
5. İlk retryable hata response stream'e client'ın görebileceği biçimde commit ediliyor mu?
6. Combo sonraki hedefe geçerken önceki hedefin hata event'i dışarı sızıyor mu?
7. Client abort sinyali yeni fallback hedefini gereksiz yere iptal ediyor mu?
8. OpenCode AI SDK'nın retry sınıflandırması status code/body/header üzerinden nasıl tetikleniyor?
9. Retry için `Retry-After`, doğru HTTP status ve backoff sağlanıyor mu?
10. Aynı modelin doğrudan OAuth yolunda başarılı, OmniRoute yolunda başarısız olmasının request payload/header/stream farkı nedir?

## Önerilen sonraki doğrulamalar

Config değiştirmeden, kontrollü testlerle:

1. Aynı OMO payload'unu OmniRoute `/v1/messages` endpoint'ine iki paralel `curl`/SDK çağrısıyla gönder; OpenCode'u devreden çıkar.
2. Aynı iki çağrıyı doğrudan provider endpoint'ine gönder; payload farklarını karşılaştır.
3. OmniRoute request correlation ID'lerini OpenCode session ID'leriyle eşleştir.
4. Response status/header/body'nin ilk retry öncesindeki ham halini artifact log'undan incele.
5. Combo testinde her hedefin başlangıç, hata, fallback ve abort zamanlarını tek correlation timeline'da çıkar.
6. Request queue/semaphore key'lerini loglayarak iki process'in neden aynı admission slot'una çarptığını doğrula.
7. Client abort edilmeden bekleyen basit bir test client'ıyla combo fallback'in başarıyla tamamlandığını doğrula.

## Geçici çalışma yolları

Kök neden düzeltilene kadar:

1. Paralel ağır OMO işleri için doğrudan OpenAI OAuth kullanmak — testle doğrulandı.
2. OmniRoute üzerinden aynı anda bir ağır Sisyphus parent request çalıştırmak.
3. OpenCode retry davranışının kontrol edilebildiği bir ayar varsa uzun backoff/az retry kullanmak.
4. OmniRoute error/fallback akışı düzeltilmeden combo'yu tek başına çözüm kabul etmemek.

`background_task.defaultConcurrency` yalnız subagent fan-out'u sınırlar; hata parent Sisyphus çağrısı alt agent başlamadan önce oluşabildiği için tek başına kök çözüm değildir.

## İlgili dosya ve kaynaklar

- OpenCode log: `~/.local/share/opencode/log/opencode.log`
- Aktif OpenCode config: `~/.config/opencode/opencode.jsonc`
- Aktif OMO config: `~/.omo/omo.jsonc`
- Önceki incident notu: `settings/opencode/docs/omo-parallel-session-root-cause.md`
- OMO schema issue: https://github.com/code-yeongyu/oh-my-openagent/issues/6515
- OmniRoute repo: `/home/ac/Code/ahmet-cetinkaya/OmniRoute`

## Upstream issue eşleşmesi ve kesin kök neden

Araştırma sonrasında incident'i birebir açıklayan açık upstream issue'lar bulundu.

### OmniRoute #9176 — binary heavyweight chat lease

Issue:

- https://github.com/diegosouzapw/OmniRoute/issues/9176
- `feat(resilience): replace the binary heavyweight chat lease with bounded phase-aware admission`

Issue mevcut tasarımı şöyle açıklıyor:

- `ChatAdmissionController.tryAcquireHeavy()` process genelinde binary bir ağır-istek sayacı kullanıyor.
- Varsayılan maksimum ağır istek sayısı `1`.
- Aşağıdaki eşiklerden herhangi birini geçen istek ağır kabul ediliyor:
  - en az 200 mesaj,
  - en az 64 tool,
  - en az 32.000 tahmini yapısal token.
- Ağır istek lease'i yalnız parsing, compression, translation veya upstream dispatch
  aşamasında değil; SSE response stream bitene, hata verene veya iptal edilene kadar
  tutuluyor.
- Slot doluyken gelen ikinci ağır istek bounded server-side queue'da bekletilmiyor;
  doğrudan `503 chat_admission_busy` ile reddediliyor.

Bu davranış testteki semptomu tam olarak açıklar:

```text
Session A ağır Sisyphus isteği
  → process-wide tek heavy lease'i alır
  → SSE stream boyunca lease'i tutar

Session B ağır Sisyphus isteği
  → aynı heavy lease dolu
  → HTTP 503 chat_admission_busy
  → OpenCode AI SDK yaklaşık 1 saniye sonra retry
  → lease hâlâ A'da olduğu için tekrar 503
```

Dolayısıyla sorun artık yalnız “OmniRoute yolu ile ilişkili” değil, daha kesin biçimde
şöyle tanımlanabilir:

> OmniRoute v3.8.49'un varsayılan process-wide ağır chat admission limiti `1` olduğu
> için iki OMO Sisyphus/ultraworker isteği aynı anda kabul edilmiyor. İkinci istek
> `503 chat_admission_busy` alıyor; OpenCode'un hızlı retry/abort davranışı semptomu
> retry storm ve `499` kayıtları şeklinde büyütüyor.

OOM korumasının kendisi gerekçelidir; problem varsayılan binary lease'in normal
multi-agent kullanımı tek ağır stream'e indirmesi ve fazla isteklerin bounded queue
yerine hemen reddedilmesidir.

### OmniRoute #9012 — mevcut sürüm için resmi workaround

Issue:

- https://github.com/diegosouzapw/OmniRoute/issues/9012
- `docs(providers): document chat_admission_busy and how to tune heavyweight chat concurrency`

OmniRoute v3.8.49'da ağır-chat limiti dashboard'daki şu ayardan bağımsızdır:

```text
Settings → Resilience → Request Queue → Concurrent Requests
```

Bu GUI ayarı genel request queue'yu kontrol eder; ağır chat-body admission slot sayısını
değiştirmez. İlgili limit yalnız environment variable ile yönetilir:

```env
OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=2
```

Docker Compose örneği:

```yaml
services:
  omniroute:
    environment:
      OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT: "2"
```

Değişiklikten sonra OmniRoute yeniden başlatılmalıdır. Issue'daki gözleme göre
varsayılan `1` değerini `2` yapmak iki eşzamanlı coding-agent isteğindeki
`chat_admission_busy` hatalarını durdurmuştur.

İki paralel OpenCode session hedefi için `2` en küçük doğru başlangıçtır. Daha yüksek
değerler parsing, compression, translation ve dispatch aşamalarındaki bellek baskısını
artırabilir; kademeli yükseltilmeli ve process/container belleği izlenmelidir.

İlgili sınıflandırma eşikleri de v3.8.49'da environment-only'dir:

```env
OMNIROUTE_CHAT_LARGE_BODY_BYTES=262144
OMNIROUTE_CHAT_HEAVY_MESSAGE_COUNT=200
OMNIROUTE_CHAT_HEAVY_TOOL_COUNT=64
OMNIROUTE_CHAT_HEAVY_ESTIMATED_TOKENS=32000
```

Eşikleri yükseltmek isteği “hafif” göstermeye çalışır ve OOM korumasını zayıflatabilir.
Önerilen ilk çözüm eşikleri değiştirmek değil, yalnız gerekli paralellik kadar
`OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT` artırmaktır.

### Hermes Agent #76468 — bağımsız client doğrulaması

Issue:

- https://github.com/NousResearch/hermes-agent/issues/76468
- `[Bug]: structured OmniRoute chat_admission_busy 503 aborts multi-agent turns instead of waiting for capacity`

Başka bir agent client aynı davranışı bağımsız olarak yeniden üretmiştir:

- bir ana uzun-running request heavy lease'i tutar,
- paralel delegated agent `503 chat_admission_busy` alır,
- hızlı client retry'ları kapasite açılmadan tükenebilir,
- multi-agent turn sonuç üretemeden sona erebilir.

Hermes issue'su server-side admission tasarımı için doğrudan OmniRoute #9176'ya
referans verir. Bu bağımsız repro, sorunun OMO'ya özgü olmadığını ve gateway-level
heavy admission davranışından kaynaklandığını doğrular.

## Güncellenmiş sonuç ve eylem planı

### Kesinleşen kök neden

```text
OmniRoute v3.8.49
  + process-wide heavy chat lease default=1
  + iki eşzamanlı ağır Sisyphus request
  → ikinci request HTTP 503 chat_admission_busy
  → OpenCode AI SDK hızlı retry/abort
  → tekrar eden 503 + OmniRoute 499 kayıtları
```

Doğrudan OpenAI OAuth testinin başarılı olmasının nedeni bu request yolunun OmniRoute
heavy admission controller'ından geçmemesidir. Claude ve Codex'in OmniRoute üzerinden
aynı hatayı vermesi de model/provider farkından değil, ikisinin aynı process-wide
admission guard'dan geçmesinden kaynaklanır.

### Uygulanacak minimal çözüm

1. OmniRoute deployment environment'ına şunu ekle:

   ```env
   OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=2
   ```

2. OmniRoute'u yeniden başlat.
3. Aynı iki-session Sisyphus paralel testini tekrar çalıştır.
4. Şunları doğrula:
   - `chat_admission_busy` yok,
   - OpenCode retry storm yok,
   - OmniRoute client-abort kaynaklı `499` yok,
   - iki session eşzamanlı ilerliyor,
   - process/container bellek kullanımı güvenli sınırda.
5. Yalnız ikiden fazla eşzamanlı ağır request gerekirse değeri birer birer artır; her
   adımda bellek ve OOM davranışını ölç.

### Uzun vadeli upstream çözüm

OmniRoute #9176'nın önerdiği phase-aware bounded admission tasarımı:

- binary process-wide lease yerine ağırlıklı/phase-aware maliyet,
- lease'i tüm SSE ömrü yerine yalnız bellek-yoğun fazlarda tutma,
- fazla istekleri hemen 503 ile reddetmek yerine bounded FIFO queue'da bekletme,
- queue timeout/cancellation/backpressure'i açık biçimde yönetme,
- `Retry-After` ve structured `chat_admission_busy` semantiğini koruma.

Client tarafı yine structured `chat_admission_busy` ve `Retry-After` değerlerini
anlamalıdır; bounded queue dolabilir veya deployment drain olabilir. Ancak mevcut
incident için en küçük server-side çözüm `OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=2`'dir.

## Doğrulama — düzeltme uygulandı (2026-08-02)

### Uygulanan değişiklik

OmniRoute'un `docker-compose` backend servis tanımına environment değişkeni eklendi:

```text
omniroute-backend:
  environment:
    - OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=2
```

Servis diğer mevcut environment değişkenleriyle (`OMNIROUTE_MEMORY_MB`, `NODE_OPTIONS`,
`REDIS_URL`, `OMNIROUTE_WS_BRIDGE_SECRET` vb.) birlikte, healthcheck'i korunarak
yeniden oluşturuldu (`--force-recreate` ile container recreate; salt restart, image
env'ini garanti güncellemeyeceği için tercih edilmedi).

### Test senaryosu

İki OpenCode süreci (`opencode-test-1.4`, `opencode-test-2.4`) eşzamanlı başlatıldı.
İkisi de OMO `Sisyphus - ultraworker` agent'ıyla, `omniroute/codex/gpt-5.6-sol`
modeliyle, alt ajan delegasyonu isteyen aynı maze-oyunu promptunu çalıştırdı.

### Gözlemlenen sonuç

Ekran görüntüsü kanıtı (2026-08-02 13:51): her iki oturum da aynı anda aktif
ilerliyordu — biri todo listesi/plan adımındaydı, diğeri dosya okuma ve alt ajan
hazırlığı yapıyordu. Hiçbirinde "Structurally heavy chat request capacity is busy"
veya "retrying attempt #N" görülmedi.

Log doğrulaması (`~/.local/share/opencode/log/opencode.log`) düzeltmeyi teyit etti:

```text
run=370b82d6  session.id=ses_03de6c043ffe...  modelID=codex/gpt-5.6-sol  (session 2.4 parent)
run=9a85c11d  session.id=ses_03de6c170ffe...  modelID=codex/gpt-5.6-sol  (session 1.4 parent)
```

İki parent session aynı zaman aralığında (10:51:03 – 10:51:58) kesintisiz `stream`
adımlarıyla ilerledi. Session 2.4 ayrıca iki alt ajan (`@explore`, `@librarian`)
başlattı ve bunlar `openai/gpt-5.6-luna-fast` üzerinden paralel çalıştı — yani hem
parent-parent hem parent-subagent paralelliği aynı anda sorunsuz çalıştı.

Log'da görülen tek `ERROR` satırları:

```text
message=cancel session.id=...
message=process ... error=Aborted
```

Bu satırlardan hemen önce `message=cancel` kaydı var — yani bu abort, sunucudan gelen
bir admission hatası değil, kullanıcı/TUI tarafından tetiklenen normal bir session
iptali. `chat_admission_busy`, `Structurally heavy...`, `499`, veya `Client
disconnected: request_signal_aborted` kayıtlarının hiçbiri bu test penceresinde
oluşmadı.

### Sonuç

| Kontrol | Düzeltme öncesi | Düzeltme sonrası |
|---|---|---|
| `chat_admission_busy` / "Structurally heavy..." | Sürekli, ~1 sn aralıklarla | Yok |
| OpenCode retry storm (`retrying attempt #N`) | Var (27, 13 gibi sayaçlara ulaştı) | Yok |
| OmniRoute `499` / client-abort kayıtları | Var (combo fallback denemelerinde) | Yok |
| İki parent session eşzamanlı ilerleme | Hayır (biri bekliyor/donuyor) | Evet |
| Parent + subagent eşzamanlı çalışma | Test edilememişti (parent zaten tıkanıyordu) | Evet, sorunsuz |

Kök neden doğrulandı ve düzeltme onaylandı: **OmniRoute'un varsayılan process-wide
ağır-istek admission limiti (`1`) iki paralel OMO Sisyphus isteğini birbirine
düşürüyordu; `OMNIROUTE_CHAT_MAX_HEAVY_IN_FLIGHT=2` bunu çözdü.**

### Kalan öneriler

- Şu an `2` değeri iki paralel ağır session ihtiyacını karşılıyor. Üç veya daha fazla
  paralel session gerekirse değer birer birer artırılmalı, her adımda container/Node
  bellek kullanımı ve OOM restart sayısı izlenmeli.
- Bu ayar OmniRoute'un kendi `docker-compose` dosyasında kalıcı olarak saklanmalı,
  imaj güncellemesi veya yeniden deploy sırasında sıfırlanmamalı.
- Uzun vadede OmniRoute #9176'daki phase-aware bounded admission tasarımı upstream'de
  yayınlanırsa, sabit `MAX_HEAVY_IN_FLIGHT` değeri yerine o mekanizmaya geçiş
  değerlendirilmeli — sabit sayı, istek başına gerçek bellek maliyetini hesaba katmaz.
- OMO tarafında ek bir değişiklik gerekmedi; `~/.omo/omo.jsonc` ve
  `~/.config/opencode/opencode.jsonc` bu incident için olduğu gibi kalabilir.
