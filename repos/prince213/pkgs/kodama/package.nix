{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "0.7.5-patch";

  src = fetchFromGitHub {
    owner = "kokic";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FsLWQt1Q1kyNL+g6vFzQpfpDouBt359iwRnDY6tcLZY=";
  };

  cargoHash = "sha256-tSAi6QhKgn7kU7kqs9DgH5qMHrKlw+N1+bV7Vv0GQbY=";

  checkFlags = [
    "--skip=process::embed_markdown::tests::test_is_assets_file"
  ];

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kokic/kodama";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
