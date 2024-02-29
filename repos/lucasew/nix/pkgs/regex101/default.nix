{ stdenv
, qtbase
, qtwebengine
, wrapQtAppsHook
, fetchFromGitHub
, cmake
, gitMinimal
}:

stdenv.mkDerivation {
  pname = "regex101";
  version = "0-unstable-2020-11-24";

  src = fetchFromGitHub {
    owner = "nedrysoft";
    repo = "regex101";
    rev = "aabb53c1f763af2c6915e22bb5b0c007a4622300";
    hash = "sha256-5iBfVv7s4goGZ59He0Nmdj22JaNeBv+wWKttfBaIkMg=";
  };

  buildInputs = [ qtbase qtwebengine ];
  nativeBuildInputs = [ wrapQtAppsHook cmake gitMinimal ];

  postBuild = ''
  find $(realpath ..) -type f
  '';
  installPhase = ''
  runHook preInstall
  mkdir -p $out/bin

  install -m755 "../bin/x86_64/Release/Regular Expressions 101" $out/bin
  ln -s $out/bin/Regular* $out/bin/regex101
  runHook postInstall
  '';
}
