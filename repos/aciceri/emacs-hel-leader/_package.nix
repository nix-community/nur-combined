{
  emacsPackages,
  callPackage,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  # Defaulted so the package stays callable with `callPackage f { }`, while the
  # emacs module can inject the single `hel` instance built against its `epkgs`.
  hel ? callPackage ../emacs-hel/_package.nix { inherit emacsPackages; },
  ...
}:
# hel extension, not on MELPA yet; build it from GitHub like hel itself.
emacsPackages.trivialBuild {
  pname = "hel-leader";
  version = "2.1-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel-leader";
    rev = "32230075e01749ace44ddf2d25fca0ba6aa98fbd";
    hash = "sha256-2cJxCJWwnGWLyodYU4rbnnQ3uzV6oWl+zATVniraDSw=";
  };

  packageRequires = [
    hel
  ]
  ++ (with emacsPackages; [
    dash
    s
  ]);

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-hel-leader --version=branch";

  meta = {
    description = "Leader key for Hel, the Emacs Helix emulation layer";
    homepage = "https://github.com/anuvyklack/hel-leader";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
