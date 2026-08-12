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

  libgit2Experimental = libgit2.override {
    withExperimentalSha256 = true;
  };

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gitbutler-cli";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-iiUgqpoLixyBG+MKQZBQbt4aCsRPrM8lPmwJHReAgPk=";
  };

  cargoHash = "sha256-iuEDFrB/ZMhRAoHopuSwH1r7mE/0hLv/bnZzdYMWGRY=";

  nativeBuildInputs = [
    cmake # Required by `zlib-sys` crate
    pkg-config
  ];

  buildInputs = [
    libgit2Experimental
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
      VERSION = finalAttrs.version;
    }
    // lib.optionalAttrs (lib.versionAtLeast libgit2Experimental.version "1.9.4") {
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
