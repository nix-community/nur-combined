{
  lib,
  dbus,
  makeWrapper,
  rocqPackages,
}:

# Patched RocqIDE that follows KDE Plasma (xdg-desktop-portal) light/dark by
# default. Upstream stays light-themed under Plasma dark, which makes Breeze
# Dark symbolic icons invisible on the white chrome; we force a dark GTK
# variant and dark editor defaults when the desktop prefers dark.
rocqPackages.rocqide.overrideAttrs (old: {
  pname = "rocqide-patched";

  patches = (old.patches or [ ]) ++ [ ./patches/0001-plasma-dark-defaults.patch ];

  postPatch = (old.postPatch or "") + ''
    cp ${./coq_style_dark.xml} ide/rocqide/coq_style_dark.xml
    substituteInPlace ide/rocqide/dune \
      --replace-fail '(coq_style.xml as coq/coq_style.xml)' \
      "$(printf '%s\n  %s' \
        '(coq_style.xml as coq/coq_style.xml)' \
        '(coq_style_dark.xml as coq/coq_style_dark.xml)')"
  '';

  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  postInstall = (old.postInstall or "") + ''
    install -Dm644 ${./follow-plasma-theme.sh} \
      "$out/libexec/rocqide/follow-plasma-theme.sh"
  '';

  # wrapGAppsHook3 uses makeBinaryWrapper, which has no --run. Add a shell
  # wrapper layer that probes Plasma/portal color-scheme before exec.
  postFixup = (old.postFixup or "") + ''
    mkdir -p "$out/libexec/rocqide"
    mv "$out/bin/rocqide" "$out/libexec/rocqide/rocqide-gapps"
    makeWrapper "$out/libexec/rocqide/rocqide-gapps" "$out/bin/rocqide" \
      --prefix PATH : "${lib.makeBinPath [ dbus ]}" \
      --run ". \"$out/libexec/rocqide/follow-plasma-theme.sh\""
  '';

  meta = (old.meta or { }) // {
    description = "RocqIDE with Plasma light/dark follow (fixes invisible icons in dark mode)";
  };
})
