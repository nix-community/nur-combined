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
- **blobl_sitter** — the tree-sitter grammar for Bloblang
  ([codeberg.org/hsctech/blobl_sitter](https://codeberg.org/hsctech/blobl_sitter)),
  packaged here as **tree-sitter-bloblang** from tagged releases.
- **helix-blobl** — hsctech's Helix fork
  ([codeberg.org/hsctech/helix](https://codeberg.org/hsctech/helix)), which
  adds Bloblang grammar and language-server support. Pinned to a commit
  (manual bumps); reuses nixpkgs' helix wrapper and grammar lockfile, with
  blobl_sitter added as an extra locked grammar. The `helix-blobl` overlay
  additionally overrides `pkgs.helix`.
