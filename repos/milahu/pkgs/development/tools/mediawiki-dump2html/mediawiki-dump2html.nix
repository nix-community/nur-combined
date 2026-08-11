{ lib
, stdenv
, go
, fetchFromGitHub
, buildGoModule
, pandoc
}:

buildGoModule rec {
  pname = "mediawiki-dump2html";
  version = "unstable-2023-02-19";

  src = fetchFromGitHub {
    owner = "willjp";
    repo = "mediawiki-dump2html";
    rev = "ecc79baa88f0346a673b5cc007dd28b9c795bb11";
    sha256 = "sha256-Hm8K0ilFEuvYxyplmAcb476L1id06ePcwluxWts1/ZY=";
  };

  vendorHash = "sha256-acbOktk5A0IIfILT81D9O4AL6wCRX8H/9sm8iHrjgOg=";

  propagatedBuildInputs = [
    pandoc
  ];

  meta = with lib; {
    description = "Convert a mediawiki xml dump to static html";
    homepage = "https://github.com/willjp/mediawiki-dump2html";
    maintainers = with maintainers; [ ];
    #license = licenses.mit;
  };
}
