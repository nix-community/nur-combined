{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "gemgen";
  version = "0.6.0";

  src = fetchFromSourcehut {
    owner = "~kota";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2oIgBcdq2tJCKyh5ob2cn2mLRd7YoeRsKy5qqu0+jPk=";
  };

  vendorHash = "sha256-KBG7RvWb0nzW9ZSPL1a65Jq9DsSHea8bKLvz6Ft5FsY=";

  nativeBuildInputs = [ scdoc ];

  meta = with lib; {
    description = "Markdown to Gemtext generator";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
