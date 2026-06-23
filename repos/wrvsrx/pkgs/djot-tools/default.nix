{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-yUHca2KUbbPLWFXjQ++Jml0wWmFQMng2Dz1QVtxYjw8=";
  };

  cargoHash = "sha256-A7EG+oyhOhy4mrP4CplEbYSKyGGgjZUuDGNKMRkH+YE=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
