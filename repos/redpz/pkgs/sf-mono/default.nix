{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation {
  name = "sf-mono";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "supercomputra";
    repo = "SF-Mono-Font";
    rev = "1409ae79074d204c284507fef9e479248d5367c1";
    hash = "sha256-3wG3M4Qep7MYjktzX9u8d0iDWa17FSXYnObSoTG2I/o=";
  };

  installPhase = ''
    runHook preInstall
    find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
    runHook postInstall
  '';


  meta = with lib; {
    homepage = "https://github.com/supercomputra/SF-Mono-Font";
    description = "Apple's SF Mono Font";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
