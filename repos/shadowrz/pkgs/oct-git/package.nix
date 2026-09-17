{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  dbus,
  sqlite,
  pcsclite,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oct-git";
  version = "0.1.8";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "openpgp-card";
    repo = "oct-git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lKgd0odI6zywgc0+rusa9B/scvFN/k5PhEyO5TskJp4=";
  };

  cargoHash = "sha256-ZugVdRKZPh5rAsPf92XW4hh7E/FBLr8Y1VhDHwEbZ3Y=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    pcsclite
    sqlite
  ];

  env = {
    LIBSQLITE3_SYS_USE_PKG_CONFIG = true;
  };

  doCheck = false; # https://codeberg.org/openpgp-card/oct-git/issues/31

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A simple tool for Git signing and verification with a focus on OpenPGP cards";
    homepage = "https://codeberg.org/openpgp-card/oct-git";
    license = with lib.licenses; [
      asl20
      mit
      cc-by-sa-40
      cc0
    ];
    maintainers = with lib.maintainers; [ shadowrz ];
    mainProgram = "oct-git";
  };
})
