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
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-S9lBnd3zhWi+0oLutujud5GyI0W+AHKvZpNvRWD2WXU=";
  };

  cargoHash = "sha256-faG1Y+5dd3BrLWIWF5ZUxXSAzd5wqbyj7/vxEHUAfjs=";

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

  env = {
    OPENSSL_NO_VENDOR = true;
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
