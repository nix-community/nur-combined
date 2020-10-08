# pnpkgs

[![Build Status](https://travis-ci.com/pniedzwiedzinski/pnpkgs.svg?branch=master)](https://travis-ci.com/pniedzwiedzinski/pnpkgs)

**My personal [NUR](https://github.com/nix-community/NUR) repository**

## `larbs-mail`

Larbs-mail is a system for automatically configuring mutt and isync with a simple interface and safe passwords. The package contains:

- `neomutt` email client with embedded configuration, that can be extended in `~/.config/mutt/muttrc`
- [`mutt-wizard`](https://github.com/LukeSmithXYZ/mutt-wizard) script for managing email accounts and mail synchronization
- `mailbox` script that can be used in your WM status bar
- `pass` for managing accounts' passwords
- `larbs-mail.desktop` file which can be pointed in `mimeapps.list`: `x-scheme-handler/mailto=larbs-mail.desktop` to use larbs-mail as default mail client

For more usage info try `mw help`

### Optional dependencies

- `gpg` - for signing and encrypting emails
- `abook` - address book with neomutt integration

## larbs-news

Newsboat RSS reader with vim bindings.

- `newsboat` rss reader
- `newsup` update script
- `news` statusbar script
- `tsp`, `qndl`, `queueandnotify`, `podentr` queuing tools
- `larbs-news.desktop` file for `mimeapps.list`: `application/rss+xml=larbs-news.desktop`

### Optional dependencies

- web browser - for viewing http links
- mpv - video player (i.e. for youtube links)
