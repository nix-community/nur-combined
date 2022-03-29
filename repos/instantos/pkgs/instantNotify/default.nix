{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, instantMenu
, sqlite
}:
stdenv.mkDerivation {

  pname = "instantNotify";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantNOTIFY";
    rev = "ad4bdbf161b39a21d64f89aa11020df90cff0285";
    sha256 = "Lb3xm43heIyHVRfGVsXWl9Y4pSoOyzeZGcq1aZU26hU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [ instantMenu sqlite ];

  makeFlags = [ "DESTDIR=$(out)/" "PREFIX=" ];

  postPatch = ''
    patchShebangs *.sh
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    make install DESTDIR=$out/ PREFIX=
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram "$out/bin/instantnotifyctl" \
      --prefix PATH : ${lib.makeBinPath [ sqlite ]}
  '';

  meta = with lib; {
    description = "Notification system for instantOS";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantNOTIFY";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
