{ stdenv
, lib
, fetchFromGitHub
, xxd
}:

stdenv.mkDerivation {
  pname = "text2image";
  version = "unstable-2022-11-24";

  src = fetchFromGitHub {
    owner = "justinmeiners";
    repo = "text2image";
    rev = "d00d2fbec6764f671aab256e4c6bd9d914ac2c07";
    hash = "sha256-yvyas1RY8uXrngQS5lyGTXp7nL8wYDNVl8eoazL6d4I=";
  };

  buildInputs = [ xxd ];

  postPatch = ''
  substituteInPlace text2image.c \
    --replace 'fopen("font/cmunrm.ttf", "rb")' 'fopen(path, "rb")'
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 text2image $out/bin 
    runHook postInstall
  '';
}
