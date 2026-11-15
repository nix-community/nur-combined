{
  callPackage,
  fetchFromGitHub,
  gitUpdater,
  lib,
}:
let
  version = "1.6.6";
  src = fetchFromGitHub {
    owner = "JohnRTitor";
    repo = "xdg-desktop-portal-gtk4";
    rev = "v${version}";
    hash = "sha256-F15UsZx/mqcHAxVbDkpYpDOqTxKvrUNGXY/D8FzyWcQ=";
  };
  pkg = callPackage "${src}/packaging/nix/package.nix" { };
in
  pkg.overrideAttrs (base: {
    inherit src version;
    # inherit version;
    # __intentionallyOverridingVersion = true;
    passthru = (base.passthru or {}) // {
      updateScript = gitUpdater {
        rev-prefix = "v";
      };
    };
    meta.platforms = lib.platforms.linux;
  })
