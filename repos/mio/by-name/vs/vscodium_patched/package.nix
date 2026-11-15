{ vscodium }:

# From-source VSCodium plus a TypeScript patch so "Add to .gitignore" escapes
# leading `#` / `!` (e.g. Emacs autosaves like `#stlc.v#` → `\#stlc.v#`).
vscodium.override {
  pname = "vscodium_patched";
  extraPatches = [ ./patches/gitignore-hash-escape.patch ];
  description = "Open source VS Code build (from source; escape leading #/! in .gitignore)";
}
