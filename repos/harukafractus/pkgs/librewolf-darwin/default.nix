{ lib, stdenvNoCC, pkgs, fetchurl }: 
let
  version = "123.0-1";
  
  x86_64_url = "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/123.0-1/librewolf-123.0-1-macos-x86_64-package.dmg";
  x86_64_sha256 = "86f5c9cbc385956cde673098ff83c905d2dc35fb4e2d1c658a1df8c8ef90f23d";
  
  arm64_url = "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/123.0-1/librewolf-123.0-1-macos-arm64-package.dmg";
  arm64_sha256 = "92f2d64d3106577036c53c93a6720b4dffde9f48998d81ed4229b46f2c13c75e";

in stdenvNoCC.mkDerivation rec {
  pname = "Librewolf";
  inherit version;

  src = fetchurl {
    name = "Librewolf-${version}.dmg";
    url = if pkgs.system == "x86_64-darwin" then x86_64_url else arm64_url;
    sha256 = if pkgs.system == "x86_64-darwin" then x86_64_sha256 else arm64_sha256;
  };

  buildInputs = [ pkgs.undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r LibreWolf.app "$out/Applications/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf.net/";
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
  };
}
