{ stdenv
, fetchFromGitHub
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "rime-dict";
  version = "20211116";
  src = fetchFromGitHub {
    owner = "Iorest";
    repo = pname;
    rev = "325ecbda51cd93e07e2fe02e37e5f14d94a4a541";
    sha256 = "sha256-LmY2EQ1VjfX9UJ8ubwoHgxDdJUicSuE0uqxKRnniJ+k=";
  };
  installPhase = ''
    mkdir -p $out/share/rime-data
    find ${src} -name "*.dict.yaml" -exec cp {} $out/share/rime-data/ \;
  '';
}
