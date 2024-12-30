{
  lib,
  stdenv,
  swiftPackages,
  darwin,
  apple-sdk_15,
  swift,
  sources,
  overrideCC,
  llvmPackages_18,
}:
stdenv.mkDerivation {
  pname = "pam-watchid";
  inherit (sources.pam-watchid) version src;

  nativeBuildInputs = [
    swift
  ];

  # buildInputs = [ apple-sdk_15 ];

  doBuild = false;

  buildPhase = ''
    runHook preBuild

    swiftc Sources/pam-watchid/pam_watchid.swift -o pam_watchid.so -emit-library

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
