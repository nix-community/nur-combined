{ stdenv, lib, fetchFromGitHub, tinycc }:

stdenv.mkDerivation rec {
  pname = "protonhax";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jcnils";
    repo = pname;
    rev = version;
    hash = "sha256-3s1pmHcQy/xJS6ke0Td3tkXAhXcTuJ4mb3Dtpxb2/6o=";
  };

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp {protonhax,envload} $out/bin

    runHook postInstall
  '';

  postFixup = ''
    patchShebangs --build $out/bin protonhax
  '';

  nativeBuildInputs = [ tinycc ];

  meta = with lib; {
    description = "Program to help executing outside programs in proton";
    homepage = "https://github.com/aoleg94/protonhax";
    platforms = [ "x86_64-linux" ];
    license = licenses.bsd3;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
