{
  lib,
  rustPlatform,
  cmake,
  pkg-config,
  fetchFromGitHub,
  libgit2,
  openssl,
  git,
  glib,
  dbus,
  nix-update-script,
  ...
}:

let
  cargoFlags = [
    "-p"
    "but"
  ];

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gitbutler-cli";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-V7lLzVADjaQMwQ8VeAlWTj5iNXRI0GNy/8Ec/q3NDUs=";
  };

  cargoHash = "sha256-XZUpK9vTlZyYcfrifru0tfM/zODzLOMAridd7ImAEc8=";

  nativeBuildInputs = [
    cmake # Required by `zlib-sys` crate
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    glib
    dbus
  ];

  nativeCheckInputs = [ git ];

  dontCargoCheck = true; # Who cares about tests?
  cargoBuildFlags = cargoFlags;

  env =
    {
      OPENSSL_NO_VENDOR = true;
    }
    // lib.optionalAttrs (lib.versionAtLeast libgit2.version "1.9.4") {
      LIBGIT2_NO_VENDOR = 1;
    };

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
        "--version-regex"
        "release/(.*)"
      ];
    };
  };

  meta = {
    description = "Command-line interface for GitButler";
    homepage = "https://gitbutler.com";
    license = lib.licenses.fsl11Mit;
    platforms = lib.platforms.linux;
    mainProgram = "but";
  };
})
