{
  buildGoModule,
  fetchFromGitHub,
  ...
} @ args:

buildGoModule rec {
  pname = "bird-lg-go";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = "950c018b187aa13edbea4d8acbb2022fd2f13319";
    sha256 = "sha256-bTGFocQel+Tz9RuPN1mebkz12P+M1C4h4bzTD8woHas=";
  };

  vendorSha256 = "101z8afd3wd9ax3ln2jx1hsmkarps5jfzyng4xmvdr4m4hd9basq";

  modRoot = "frontend";
  checkPhase = "";
}
