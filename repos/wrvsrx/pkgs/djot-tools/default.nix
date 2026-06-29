{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-/pRc/e1Mi9nEvVtYnIKoajT4WMuIQgBfKc6cTMLXpGY=";
  };

  cargoHash = "sha256-y1qiu+sXwJeIuZn17DjWc67LzOMFvB5AMv6ljjVjWdY=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
