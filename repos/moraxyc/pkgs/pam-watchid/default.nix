{
  lib,
  stdenv,
  fetchFromGitHub,
  swift,
}:

stdenv.mkDerivation {
  pname = "pam-watchid";
  version = "unstable-2024-12-23";

  src = fetchFromGitHub {
    owner = "Logicer16";
    repo = "pam-watchid";
    rev = "505f008c1cb0a6fb9a30819422779bce9d37138c";
    hash = "sha256-nQxqltci3zzETblYPijqvzsRqtn5JI7Br0ydrfmyE7A=";
  };

  nativeBuildInputs = [
    swift
  ];

  doBuild = false;

  buildPhase = ''
    runHook preBuild

    swiftc watchid-pam-extension.swift -o pam_watchid.so -emit-library

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 444 -t $out/lib/security/ pam_watchid.so

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Logicer16/pam-watchid";
    platforms = lib.platforms.darwin;
  };
}
