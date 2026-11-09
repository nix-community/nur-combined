{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  alsa-lib,
  autoconf,
  automake,
  clang,
  libtool,
  m4,
  pkg-config,
  mpg123,
  speex,
  sqlite,
  libvorbis,
  flac,
  libopus,
  lame,
}:
stdenv.mkDerivation {
  pname = "utu";
  version = "unstable-2022-10-11";

  src =
    fetchFromGitHub {
      owner = "madronalabs";
      repo = "utu";
      rev = "0b5c7b4ae5cf927d0c2a5e4d0023eb95cee73900";
      hash = "sha256-7YFCpWKTKadHvw2RKmMLAE2hUzgiL2Tp3nafNL4Uuzw=";
      fetchSubmodules = true;
      # Newer nixpkgs fetchgit ignores GIT_CONFIG_COUNT env rewrites;
      # GIT_CONFIG_GLOBAL (this file) is honored instead.
      gitConfigFile = builtins.toFile "utu-gitconfig" ''
        [url "https://github.com/"]
          insteadOf = ssh://git@github.com/
      '';
    };

  buildInputs = [
    alsa-lib
    flac
    lame
    libopus
    libvorbis
    mpg123
    speex
    sqlite
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    m4
    pkg-config
    clang
    cmake
  ];

  # Vendored dep/docopt declares cmake_minimum_required < 3.5, which CMake 4 rejects.
  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin ./bin/Release/utu

    runHook postInstall
  '';

  meta = {
    description = "Utu is a command-line program that uses the Loris library to analyze sounds";
    homepage = "https://github.com/madronalabs/utu";
    license = lib.licenses.gpl2Only;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "utu";
    platforms = lib.platforms.all;
  };
}
