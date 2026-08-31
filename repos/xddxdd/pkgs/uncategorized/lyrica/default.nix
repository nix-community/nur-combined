{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
  pkg-config,
  dbus,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lyrica";
  version = "0.24";
  src = fetchFromGitHub {
    owner = "chiyuki0325";
    repo = "lyrica";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1CJWqbOGND00+xziSnaZVWtvnfhV9epKd7GVbAOQZvw=";
  };
  cargoHash = "sha256-WvrEMl41MuFqCfCHCURv6ZsDiDJGeVByCYRVuDW+2BE=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    openssl
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/chiyuki0325/lyrica/releases/tag/v${finalAttrs.version}";
    mainProgram = "lyrica";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Linux desktop lyrics widget focused on simplicity and integration";
    homepage = "https://github.com/chiyuki0325/lyrica";
    # Upstream did not specify license
    license = lib.licenses.unfreeRedistributable;
  };
})
