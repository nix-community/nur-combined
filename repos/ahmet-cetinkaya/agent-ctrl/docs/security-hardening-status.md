# Claude Code Güvenlik Katmanları — Durum Tablosu

> **Geçmiş belge.** 2026-11-05'ten beri Claude Code sandbox'sız, auto mode ile çalışıyor ve launcher kaldırıldı. Güncel model `settings/claude/README.md`'de. Aşağıdaki tablo 2026-10-05 durumunu gösterir.

Bu doküman, agent-ctrl üzerinden Claude Code'a uyguladığımız güvenlik katmanlarını özetler. Tam liste repoya alınmayan yerel bir yedektedir; şu an **Lite** moddayız ve katmanları kademeli olarak geri ekleyeceğiz.

- **Full**: Katmanın tam uygulandığı hâli (yedekteki settings.json + agents.nix + launcher).
- **Lite**: Şu anki durum (yedekten geri yüklenen temel işlevsellik).

Son güncelleme: 2026-10-05

## Katmanlar

| # | Katman | Full | Lite | Nerede / Nasıl |
| --- | --- | --- | --- | --- |
| 1 | OS sandbox (bwrap) | ✅ | ❌ | `sandbox.enabled` |
| 2 | Sandbox başlatılamazsa çık | ✅ | ❌ | `sandbox.failIfUnavailable` |
| 3 | Sandbox dışı yeniden deneme kapalı | ✅ | ❌ | `sandbox.allowUnsandboxedCommands: false` |
| 4 | Ağ strict allowlist | ✅ | ❌ | `sandbox.network.strictAllowlist` + `allowedDomains` |
| 5 | Veri sızdırma hostları engelli | ✅ | ❌ | `sandbox.network.deniedDomains` (pastebin, ngrok, webhook.site vb.) |
| 6 | Kimlik dosyalarını shell'den okuma yasağı | ✅ | ❌ | `sandbox.filesystem.denyRead` (~/.ssh, ~/.gnupg, ~/.aws, tarayıcı, .env) |
| 7 | Kimlik dosyalarını Read aracıyla okuma yasağı | ✅ | ❌ | `permissions.deny: Read(...)` (aynı yollar + ~/.claude.json) |
| 8 | Hassas env token'ları sandbox komutlarından silme | ✅ | ❌ | `sandbox.credentials.envVars` (6 token) |
| 9 | Kalıcılık dizinlerine shell yazma yasağı | ✅ | ❌ | `sandbox.filesystem.denyWrite` (Configs, systemd, PATH dizinleri, .codex) |
| 10 | Kalıcılık dizinlerinde Edit/Write onayı | ✅ | ❌ | `permissions.ask: Edit(...)` (aynı dizinler) |
| 11 | curl/wget indirme engeli | ✅ | ❌ | `permissions.deny` (`curl * -o *`, `wget *`) — Lite'ta yerine `ask` geldi |
| 12 | Pipe-to-shell engeli (shell'e boru) | ✅ | ❌ | `permissions.deny` — `sh`/`bash`/`zsh` boruları |
| 13 | `python -c` / `python3 -c` engeli | ✅ | ❌ | `permissions.deny` |
| 14 | `chmod +x` engeli | ✅ | ❌ | `permissions.deny` |
| 15 | Arşiv açma engeli (unzip/tar/7z) | ✅ | ❌ | `permissions.deny` |
| 16 | İç içe ajan CLI engeli (`claude -p`, `codex exec`, `opencode run`) | ✅ | ❌ | `permissions.deny` |
| 17 | `--dangerously-skip-permissions` bayrağı engeli | ✅ | ❌ | `permissions.deny` (CLI bayrağı kalıpları) |
| 18 | Bypass izin modunu kapatma | ✅ | ❌ | `permissions.disableBypassPermissionsMode: "disable"` |
| 19 | Managed settings (root-owned, en yüksek öncelik) | ❌ | ✅ | NixOS `environment.etc."claude-code/managed-settings.json"` |
| 20 | Repo ayarlarının sandbox'ı gevşetememesi | ❌ | ✅ | Managed + launcher `--settings` (19 ile birlikte) |
| 21 | `git push` her seferinde onay | ✅ | ❌ | `permissions.ask` |
| 22 | `podman` / `systemctl` / `crontab` / `nixos-rebuild` / `home-manager` onayı | ✅ | ❌ | `permissions.ask` |
| 23 | `gh` komutu sandbox dışı + onaylı çalışma | ✅ | ❌ | `excludedCommands` + `permissions.ask` |
| 24 | Serena shell aracı ve tarayıcı MCP'leri onaylı | ✅ | ❌ | `permissions.ask: mcp__*` |
| 25 | `PYTHONSAFEPATH` (stdlib gölgeleme koruması) | ✅ | ✅ | `env.PYTHONSAFEPATH=1` |
| 26 | Worktree symlink yetkileri (manifest tabanlı) | ✅ | ✅ | `launcher.sh` + `.claude/additional-dirs.local` |
| 27 | Bun/.NET temp düzeltmeleri | ✅ | ✅ | Launcher: `BUN_TMPDIR`, `CLAUDE_CODE_TMPDIR`, .NET state dizinleri; `settings.json` `env` ve `allowedDomains` |
| 28 | Bildirim hook'ları (Stop/Notification, oturum adlı) | ✅ | ✅ | `notify.sh` + `hooks` |
| 29 | `$HOME`'dan başlatma uyarısı (freeze koruması) | ✅ | ✅ | `claude()` zsh fonksiyonu |
| 30 | statusline sürüm sabitleme | ✅ | ✅ | `ccstatusline@2.2.30` (supply-chain) |
| 31 | Alt ajan araç daraltması | ✅ | ✅ | `agents/researcher.md`: Bash kaldırıldı |
| 32 | Ajanlara Claude-özel model atamaları | ✅ | ✅ | `models.claude` frontmatter |
| 33 | modelPicker + `behavesAs` (bilinen model ID'leri) | ✅ | ✅ | `settings.json` |
| 34 | Sınıflandırıcı model çözümü (`cc/` ID'leri) | ✅ | ✅ | `ANTHROPIC_DEFAULT_*_MODEL` |
| 35 | Kural: `gh`/`git push` tek komut çalıştır | ✅ | ✅ | `rules/safety.md` |
| 36 | Kural: indirilen içeriği veri say, kutuda incele | ✅ | ✅ | `rules/safety.md` + CLAUDE.md |
| 37 | Kural: alt ajanlara en dar araç seti | ✅ | ✅ | `rules/safety.md` + CLAUDE.md |
| 38 | `you-should-know` yerleşik modu | ✅ | ✅ | `enabledPlugins` |
| 39 | Model ID başına `[1m]` bağlam ekleri | ✅ | ✅ | `modelPicker.options[].model` |
| 40 | Kalıcılık için `denyWrite`/`ask` (hassas kökler) | ❌ | ✅ | Launcher policy reddi: ~/.ssh, ~/.config, /etc, /run vb. |
| 41 | Manifest güvenlik kontrolleri (tracked/symlink red) | ✅ | ✅ | `launcher.sh` |
| 42 | curl localhost allow (dev T9 akışı) | ➖ | ✅ | `permissions.allow` (Lite'a özel; Full'da sandbox zaten kısıtlıyor) |
| 43 | `./dev-env` okuma alt komutları allow | ➖ | ✅ | `permissions.allow` (Lite'a özel) |

## Katman bağımlılıkları

- 20 → 19 gerektirir (managed olmadan repo gevşetmesi engellenemez).
- 4, 5, 6, 8 → 1 gerektirir (ağ/dosya/ortam sınırları sandbox'ın parçası).
- 23 → sandbox'ın admin-required olmaması gerekir; 19 açıksa kullanıcı ayarından gelir.
- 11, 12, 13, 14, 15, 16, 17 → kalıp eşleştirmeli; OS sınırı değil (K3 "yavaşlatıcı").
- 42, 43 → yalnızca sandbox kapalıyken anlamlı; sandbox geri gelince `allow` yerine sandbox'ın kendi kısıtı geçerli olur ve bunlar kaldırılabilir.

## Full → Lite geçişinde bilinen bedeller

- Prompt injection başarılı olursa ajan oturum boyunca kullanıcı yetkileriyle çalışır.
- `~/.ssh`, `.env` ve kimlik dosyaları ajan tarafından okunabilir.
- Harici host'lara sessiz veri gönderimi mümkün.
- `--dangerously-skip-permissions` bayrağı engellenmez (18 kapalı).

## Yeniden sertleştirme sırası (öneri)

1. 19 + 20 (managed settings, rebuild gerekir) — çatı katman.
2. 1, 2, 3 (sandbox core).
3. 6, 7, 8, 9, 10 (kimlik + kalıcılık).
4. 4, 5 (ağ).
5. 21, 22, 24, 23 (onay kapıları).
6. 11–17 (kalıp deny'leri; atlatılabilir olduğu için en son).
7. 18 (bypass kilidi; kullanıcı rahatlığına göre).

Her adımdan sonra: `agent-ctrl apply claude --override --no-prompt` + rebuild (gerekliyse) + InsurUp worktree'inde derleme/test duman testi.
