---
name: notify-me
description: >
  Sending messages "to me" (notifications) using sendmail on this dotfiles/NixOS setup.
  The sendmail command is backed by telegram-sendmail, which delivers to
  the user's Telegram. Use for "send X to me", notifications, results, tests.
  Triggers: sendmail, send to me, notify me, notify-me, message to self, banana.
---

# notify-me

Here, `sendmail` is wrapped by `telegram-sendmail`. Mail ends up in Telegram, not a mailbox.

## Command

Use the wrapper binary:

```bash
/run/wrappers/bin/sendmail << 'ENDMAIL'
Subject: Short descriptive title
From: grok@whiterun
To: lucas59356@gmail.com

Message body here.
Multi-line is fine.
Keep it mostly ASCII to avoid UTF-8 queue issues.
ENDMAIL
```

- `sendmail` on PATH is usually the same wrapper.
- `To:` (and argv recipients) are mostly ignored; delivery goes to the configured Telegram chat.
- Success prints `OK` (enqueued for the daemon).

One-liner:

```bash
printf 'Subject: test\n\nbanana\n' | /run/wrappers/bin/sendmail
```

Prefer a heredoc for anything longer.

## Repo wiring

- `services.telegram-sendmail.enable = true` on riverwood and whiterun
- module: `nix/nodes/common/services/telegram_sendmail.nix`
- creds: `secrets/telegram_sendmail.env` (sops; `MAIL_TELEGRAM_TOKEN`, `MAIL_TELEGRAM_CHAT`)
- other callers: `nix/nodes/common/services/cloud-savegame.nix`, `bin/qrun`
- identity in `flake.nix`: user `lucasew`, email `lucas59356@gmail.com`

## When the user wants a ping

1. Minimal message with a clear `Subject`.
2. Pipe or heredoc into `/run/wrappers/bin/sendmail`.
3. Say it went out via sendmail (Telegram).

Skip `mail` / `mutt` / `msmtp` unless they ask. sendmail is the path here.
