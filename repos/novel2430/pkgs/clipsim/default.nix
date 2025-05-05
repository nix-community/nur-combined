{stdenv, fetchFromGitHub, lib
, gnumake
, xclip
, xorg
, file
, pkg-config
}:
stdenv.mkDerivation {
  pname = "clipsim";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "lucas-mior";
    repo = "clipsim";
    rev = "d576522aa24020a6dd02f9aff765ecf299b69dc5";
    sha256 = "sha256-rKyfW1C8BZRYX6iuFynrYpM87vKnLwzzZJOw+cIC66M=";
  };

  buildInputs = [
    xclip
    xorg.libXfixes
    file
    xorg.libX11
  ];

  nativeBuildInputs = [ 
    gnumake 
    pkg-config
  ];

  installPhase = ''
    mkdir -p $out
    make install DESTDIR="$out" PREFIX=/
  '';

  meta = with lib; {
    description = "Simple and fast X clipboard manager written in C.";
    homepage = "https://github.com/lucas-mior/clipsim";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ agpl3Only ];
  };
}
