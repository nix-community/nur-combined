{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-L9ZvEgZQDoNwockf+EFX6aU+xQSJJKcAhNn+GwjRnVU=";
  };

  cargoHash = "sha256-gi3ZTq+CXx+P0Nz8SCycSthRGb7W+59jmfIWKqwxS8w=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
