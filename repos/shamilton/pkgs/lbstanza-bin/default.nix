{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, gcc-unwrapped
}:

stdenv.mkDerivation rec {
  pname = "lbstanza-bin";
  version = "0.18.15";

  src = fetchzip {
    url = "https://github.com/StanzaOrg/lbstanza/releases/download/${version}/lstanza_${lib.replaceStrings ["."] ["_"] version}.zip";
    sha256 = "sha256-ByleTNhlQSiTk+dmmpmUUFR/BWL//Z0EBttLoqUwhrk=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  preBuild = ''
    addAutoPatchelfSearchPath ${gcc-unwrapped.lib}/lib
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r * "$out"
    cp "$out/stanza" "$out/bin/stanza"

    runHook postInstall
  '';

  meta = with lib; {
    description = "L.B. Stanza Programming Language";
    license = licenses.mit;
    homepage = "http://lbstanza.org/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
