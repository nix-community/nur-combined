{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-PgDZYwjmbHQnA3Aa9RuSG2VcD+O+Alc3UhQn1rubp/A=";
  };

  cargoHash = "sha256-IS0bLkLpPCWgiQYj+Ccxwnu3hg86MCfslr7RyMWg8v4=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
