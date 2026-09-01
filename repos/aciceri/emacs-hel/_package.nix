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
  version = "new_undo_system-unstable-2026-09-01";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "fa057cbe9abf98cf2c68a6c5cb775cb896e18ac4";
    hash = "sha256-ibc7aeYNEcGaCuieTcJiDrbksI+72AlT/CycqlSLAd8=";
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
