{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "odict";
  version = "2021-01-08";

  src = fetchFromGitHub {
    owner = "TheOpenDictionary";
    repo = "odict";
    rev = "639dbab4feac15c4f69049bfb9b7bcfecaf68b47";
    hash = "sha256-cshWHsFTcejNNz/95FNkadXx8XWOW0fjlJTl4POR07k=";
  };

  vendorSha256 = "sha256-+gHYFbCZkfsfsdSZvmbQho4JUn3RRQpKBcxrylpaB9g=";

  meta = with lib; {
    description = "A blazingly-fast portable dictionary file format";
    homepage = "https://odict.org/";
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
