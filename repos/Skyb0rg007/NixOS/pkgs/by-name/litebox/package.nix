{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "litebox";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "litebox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O6uxFiKxV3ek9Z9U58QNgrLdWc7hAlb7gbxaOZPh6+U=";
  };

  cargoHash = "sha256-UtRxk7fKeqIUz1raRc+oERDNV/BR4muwTo4L8H5UJyY=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Security-focused library OS";
    license = lib.licenses.mit;
    homepage = "https://github.com/microsoft/litebox";
    platforms = lib.platforms.linux;
  };
})
