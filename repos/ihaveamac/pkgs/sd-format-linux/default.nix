{
  stdenv,
  lib,
  fetchFromGitHub,
  util-linux,
  makeWrapper,
}:

let
  inherit (stdenv.hostPlatform) isStatic;
in
stdenv.mkDerivation rec {
  pname = "sdFormatLinux";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "profi200";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AoAhP1dr+hQSnOpZC0oHt0j3fUVNVhD+3jWm6iMfskk=";
  };

  buildInputs = lib.optionals (!isStatic) [ util-linux ];
  nativeBuildInputs = lib.optionals (!isStatic) [ makeWrapper ];

  makeFlags = [
    # without this, TARGET will become "source"
    # because it thinks it's building at /build/source
    "TARGET=sdFormatLinux"
    # forcing these will make it work regardless of toolchain or target platform
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "AS=${stdenv.cc.targetPrefix}as"
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  # remove hardcoded path to lsblk, and instead put "lsblk" only
  # trying to insert the full path will make the string longer than 64 characters
  # so instead the binary will be wrapped to insert util-linux into PATH
  # BUT for static builds, we cannot use a wrapper like this,
  # so we just have to hope lsblk is in PATH
  patchPhase = lib.optionalString (!isStatic) ''
    substituteInPlace source/blockdev.cpp \
      --replace-fail /usr/bin/lsblk lsblk
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp sdFormatLinux $out/bin
    ${lib.optionalString (!isStatic) ''
      wrapProgram $out/bin/sdFormatLinux \
        --prefix PATH : ${lib.makeBinPath [ util-linux ]}
    ''}
  '';

  meta = with lib; {
    description = "Properly format SD cards under Linux.";
    homepage = "https://github.com/profi200/sdFormatLinux";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "sdFormatLinux";
  };
}
