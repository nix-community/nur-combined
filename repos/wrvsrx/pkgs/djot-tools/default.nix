{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-VVgES9bFTZW5iZ42fLS+J9d1M2omZ0RoHNIB3wFAvUY=";
  };

  cargoHash = "sha256-hsB54UP7mESwayz5DQ6kS+ysSA/ZLbrHiqvzhixvBcE=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
