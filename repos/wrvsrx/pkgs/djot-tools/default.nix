{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-8DXVCALedwQ2/351fERYfvg/z9WtsL6EqifqOIkMnpc=";
  };

  cargoHash = "sha256-9pC+9hUs2e8cjpn3DX/THmWVrjewD7MQrEG6oJaUkDA=";
})
