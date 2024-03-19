{ lib, stdenvNoCC, pkgs, fetchurl }: 
let
  version = "123.0.1-1";
  
  x86_64_url = "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/123.0.1-1/librewolf-123.0.1-1-macos-x86_64-package.dmg";
  x86_64_sha256 = "15cbfc5ca15c55c742f55556315ee9176c660288e5c8524c9e0035d2b3e012f5";
  
  arm64_url = "https://gitlab.com/api/v4/projects/44042130/packages/generic/librewolf/123.0.1-1/librewolf-123.0.1-1-macos-arm64-package.dmg";
  arm64_sha256 = "e9a8ee4a3fa132bc7ea9a0962be4a5d806ab95147176cf56291bdebb820ecd80";

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
