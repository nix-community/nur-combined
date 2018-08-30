{ stdenv, fetchFromGitHub, dmd, dub, git }:

stdenv.mkDerivation rec {
  name = "literate";
  version = "b6bfcbb";

  src = fetchFromGitHub {
    owner = "zyedidia";
    repo = "Literate";
    rev = version;
    sha256 = "113y3vhgfk6a74dii3hd1icjx6fpzyklcj50wcksbphzpnzz0jiz";
  };

  buildInputs = [ dmd dub git ];

  installPhase = ''
    install -dm755 $out/bin
    install -m755 -t $out/bin/ bin/*
  '';

  # TODO: meta
  meta = with stdenv.lib; {
    description = "A literate programming tool for any language";
    homepage = http://literate.zbyedidia.webfactional.com;
    repositories.git = git://github.com/zyedidia/Literate.git;

    license = licenses.mit;

    platforms = platforms.darwin;
    maintainers = with maintainers; [ yurrriq ];
  };
}
