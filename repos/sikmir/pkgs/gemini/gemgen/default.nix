{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
}:

buildGoModule (finalAttrs: {
  pname = "gemgen";
  version = "0.6.0";

  src = fetchFromSourcehut {
    owner = "~kota";
    repo = "gemgen";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2oIgBcdq2tJCKyh5ob2cn2mLRd7YoeRsKy5qqu0+jPk=";
  };

  vendorHash = "sha256-KBG7RvWb0nzW9ZSPL1a65Jq9DsSHea8bKLvz6Ft5FsY=";

  nativeBuildInputs = [ scdoc ];

  meta = {
    description = "Markdown to Gemtext generator";
    homepage = "https://sr.ht/~kota/gemgen";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
