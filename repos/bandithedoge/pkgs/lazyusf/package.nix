{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  flac,
  libao,
  libogg,
  ninja,
}:
stdenv.mkDerivation {
  pname = "lazyusf";
  version = "0-unstable-2022-04-29";
  src = fetchFromGitHub {
    owner = "derselbst";
    repo = "lazyusf";
    rev = "17a078d3a8bb7762a33f1db4465f250947bca67a";
    hash = "sha256-nAMDluO86goZTNuqItnNv5501KVS/UmlrhWdcL+H/p8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    flac
    libao
    libogg
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Converter for Ultra 64 Sound Format";
    homepage = "https://github.com/derselbst/lazyusf";
    platforms = lib.platforms.unix;
    mainProgram = "lazyusf";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
