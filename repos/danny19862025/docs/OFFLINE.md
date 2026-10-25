# Offline dictionary and translation

Use `translate word` or `offline word` to search installed dictionaries. Use `translate en es cat` or `translate en-es cat` to select a bilingual pair. Select a database from `dictionaries`, or use `translate @database-name word`. Enter opens the definition inside Spotlight, with Copy All for copying it.

This is dictionary-based word and headword-phrase translation. It does not run AI models or translate arbitrary sentences. A match must exist in the installed lexicon. Language aliases include English, Spanish, French, German, Italian, Portuguese, Japanese, Chinese, Korean, Russian, and Arabic ISO codes; the corresponding dictionary still needs to be installed.

Spotlight reads dictd `.index` plus `.dict`, `.dict.dz`, or `.dict.gz` pairs directly. Put them in `$XDG_DATA_HOME/spotlight/dictionaries` (normally `~/.local/share/spotlight/dictionaries`), optionally in subfolders. Standard `/usr/share/dictd`, `/usr/local/share/dictd`, `/usr/share/dict`, and the XDG `dictd` directory are also searched. Compressed dictionaries need `gzip`; uncompressed dictionaries require no server or external reader.

[FreeDict](https://freedict.org/downloads/) provides bilingual data in dictd format. Download the desired pair's **dictd** archive, extract it into the dictionary folder, and retain its README/COPYING files. Dictionaries are separate from Spotlight's code and retain their original licenses. Dictionary data is installed separately and is not bundled with the launcher. When provisioning data, retain the source URL, version, and archive checksum beside it in a `SOURCE.json` file.

If direct file lookup finds no match, Spotlight also tries a DICT server on `127.0.0.1:2628` or `[::1]:2628`. You may use your distribution's `dictd` service with its configured dictionaries. Spotlight speaks the native DICT protocol itself and does not need the `dict` CLI. It never reads remote server settings from a dict client configuration, contacts an internet dictionary, or starts a dictionary daemon automatically. Queries stay local and out of saved usage history.

Lookups are case-insensitive exact headword matches. Limits are 64 discovered dictionaries, up to 16 searched per query, 32 MiB per index, 64 KiB per entry, 256 MiB compressed-stream offsets, a three-second decompression deadline, and bounded localhost socket timeouts. A missing headword produces a useful no-match message; it never falls back to an online translator. Existing `define`/`dictionary` commands remain the separately labeled online dictionary feature.
