{
  emacsPackages,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  ...
}:
# hel (Helix emulation layer) is not on MELPA yet, so build it from GitHub.
# Dependencies come from `emacsPackages` so they match the Emacs this package
# is compiled against (the emacs module passes its own `epkgs`).
emacsPackages.trivialBuild {
  pname = "hel";
  version = "new_undo_system-unstable-2026-09-02";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "7c133defda8c0e3c6c791cde05450c3d43616f06";
    hash = "sha256-Ei2WbCNEl2AzfYj7yGY2rMtJayARkC7nPhVsepDalE0=";
  };

  packageRequires = with emacsPackages; [
    dash
    avy
    pcre2el
    ultra-scroll
  ];

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-hel --version=branch";

  meta = {
    description = "Helix emulation layer for Emacs";
    homepage = "https://github.com/anuvyklack/hel";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
