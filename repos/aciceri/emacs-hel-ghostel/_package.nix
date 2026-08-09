{
  emacsPackages,
  callPackage,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  # Both are defaulted so the package stays callable with `callPackage f { }`;
  # the emacs module injects its own `hel` and its darwin-patched `ghostel`.
  hel ? callPackage ../emacs-hel/_package.nix { inherit emacsPackages; },
  ghostel ? emacsPackages.ghostel,
  ...
}:
# hel extension, not on MELPA yet; build it from GitHub like hel itself.
emacsPackages.trivialBuild {
  pname = "hel-ghostel";
  version = "0.3.0-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel-ghostel";
    rev = "999df8dfa84cb0074e8ae739262c1cbba9e3d3f3";
    hash = "sha256-1NMGK6PBAKWdK/BCyQmmxBr2T4fx2yvU5wzbM4TSGL0=";
  };

  packageRequires = [
    hel
    ghostel
  ];

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-hel-ghostel --version=branch";

  meta = {
    description = "Hel integration for the Ghostel terminal emulator";
    homepage = "https://github.com/anuvyklack/hel-ghostel";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
