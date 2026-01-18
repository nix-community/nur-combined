{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  nettle,
  gmp,
}:

let
  fatfs = fetchFromGitHub {
    owner = "devkitPro";
    repo = "fatfs-mod";
    rev = "6d3e8f89202223bf70e957357dd31405b17d1f95";
    hash = "sha256-6BklhBDDsenhO/nUjeRFDfQ7mrWPWQZbCizRB9XWsD4=";
  };
  fatfspp = fetchFromGitHub {
    owner = "TuxSH";
    repo = "fatfspp";
    rev = "8f5ba805ddaf85c15bc4e4c177ffe4725f858de0";
    hash = "sha256-JPGUqQLLgitnSmZvHspplYl+g9ihCd01kLhphMlpQpo=";
  };
in
stdenv.mkDerivation rec {
  pname = "twlnandtool";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "TuxSH";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6utNsihYD5YPyq4UiD7ZiChPnqt7e5g4lFHmO2S6zwA=";
  };

  buildInputs = [
    nettle
    gmp
  ];

  cmakeFlags =
    if stdenv.hostPlatform.isWindows then
      [
        "-DNettle_INCLUDE_DIR=${nettle.dev}/include"
        "-DNettle_LIBRARY=${nettle}/lib${stdenv.hostPlatform.extensions.sharedLibrary}"
      ]
    else
      [ ];

  # don't think pkg-config is really required
  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  postPatch = ''
    cp -r --no-preserve=mode ${fatfspp} fatfspp
    cp -r --no-preserve=mode ${fatfs} fatfspp/fatfs
  '';

  installPhase = ''
    echo $PWD
    mkdir -p $out/bin
    cp twlnandtool${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  passthru = { inherit fatfs fatfspp; };

  meta = with lib; {
    description = "Modern drop-in replacement for twltool: fast decryption of DSi NAND dumps and system files. Written in C++14";
    homepage = "https://github.com/TuxSH/twlnandtool";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    # due to issues with finding nettle
    broken = !stdenv.hostPlatform.isLinux;
    mainProgram = "twlnandtool";
  };
}
