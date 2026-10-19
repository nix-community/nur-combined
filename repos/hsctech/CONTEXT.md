# CONTEXT

Glossary for this repository.

## Terms

- **NUR** — the [Nix User Repository](https://github.com/nix-community/NUR), a
  meta-repository of user-maintained package repositories.
- **nur-packages** — this repository; hsctech's NUR repository. It is fetched
  whole by NUR's evaluator and by users, so it is kept slim.
- **NUR key** — the attribute name under which this repository appears in NUR's
  `repos.json` and to users: `hsctech` (as in `nur.repos.hsctech.<package>`).
- **Package namespace** — the top-level attributes of `default.nix`; each is a
  derivation callable with `pkgs` from nixpkgs-unstable. `overlays`, `lib`,
  and `modules` are reserved names with special meaning to NUR.
- **blobl_lsp** — a language server for Bloblang (Bento's mapping language),
  packaged here from tagged releases of
  [codeberg.org/hsctech/blobl_lsp](https://codeberg.org/hsctech/blobl_lsp).
