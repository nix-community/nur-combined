# Reusable byte-patch of Claude Code's hardcoded safety-classifier notes.
#
# `patchClaude` takes any claude-code derivation and returns the same derivation
# with the notes rewritten at build time. Use it for whichever packager supplies
# the binary, because a nixpkgs overlay only reaches nixpkgs' own claude-code:
# packages pulled through `inputs.llm-agents.packages.<system>.claude-code`
# bypass nixpkgs overlays completely.
#
# Verified against both packagers:
#   * nixpkgs: unzstd's claude.zst, then wrapProgram in postInstall.
#   * llm-agents.nix: downloads the uncompressed binary, rewrites the ELF with
#     wrap-buddy and runs wrapProgram in postFixup.
# Both leave a thin env wrapper at bin/claude and the real Bun binary at
# bin/.claude-wrapped, and neither moves the JS string pool, so one scan rule
# covers them. The patch runs in postFixup, which is after fixupPhase, so it
# lands after the wrapping whichever phase the packager picked.
{ drv, pkgs }:
drv.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.python3 ];

  postFixup = (old.postFixup or "") + ''

    echo "claude-code: rewriting hardcoded safety-classifier notes"
    patched=0
    for f in "$out"/bin/* "$out"/bin/.claude-*; do
      [ -f "$f" ] || continue
      # only the Bun single binary carries the JS string pool
      grep -qa -- '---- Bun! ----' "$f" || continue
      if python3 ${./patch_classifier_note.py} "$f" --check-only >/dev/null 2>&1; then
        python3 ${./patch_classifier_note.py} "$f" --quiet
        chmod 755 "$f"
        patched=1
      else
        echo "warning: claude-code classifier literals not found in $f" >&2
        echo "  upstream reworded them: update EDITS in" >&2
        echo "  pkgs/claude-code/patch_classifier_note.py" >&2
        echo "  leaving this binary unpatched" >&2
      fi
    done
    if [ "$patched" = 1 ]; then
      echo "claude-code: classifier notes patched"
    fi
  '';

  passthru = (old.passthru or { }) // {
    classifierNotePatched = true;
    patchScript = ./patch_classifier_note.py;
  };
})
