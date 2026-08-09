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
  version = "new_undo_system-unstable-2026-08-03";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel";
    rev = "d58cd5dc0f2e54f5a5bf5e16230c377410557099";
    hash = "sha256-xKU0DaGBFOU1gt/u02ELgbpfXusSMdetFUX64aNaK5c=";
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
