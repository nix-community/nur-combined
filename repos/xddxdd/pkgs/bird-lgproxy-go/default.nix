{
  buildGoModule,
  fetchFromGitHub,
  ...
} @ args:

buildGoModule rec {
  pname = "bird-lgproxy-go";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "950c018b187aa13edbea4d8acbb2022fd2f13319";
    sha256 = "sha256-bTGFocQel+Tz9RuPN1mebkz12P+M1C4h4bzTD8woHas=";
  };

  vendorSha256 = "1viqzzz884rasfrlj4wbq0irkvd6s9jp70qgn5218jriiq4mxdpc";

  modRoot = "proxy";
  checkPhase = "";
}
