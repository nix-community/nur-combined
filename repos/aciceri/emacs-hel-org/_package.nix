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
  pname = "hel-org";
  version = "0-unstable-2026-07-09";

  src = fetchFromGitHub {
    owner = "anuvyklack";
    repo = "hel-org";
    rev = "3d7dc4e4e05533f319a05da17d8defe36d6b35b7";
    hash = "sha256-73128sCRot/B//mqZ9gRJa25a57S+T/Wg2QQlYbtUOU=";
  };

  packageRequires = [ hel ];

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-hel-org --version=branch";

  meta = {
    description = "Hel integration with Org mode";
    homepage = "https://github.com/anuvyklack/hel-org";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
