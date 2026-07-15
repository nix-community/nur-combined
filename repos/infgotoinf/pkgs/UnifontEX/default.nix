{
  lib,
  stdenvNoCC,
  fetchurl,
}:

# stdenvNoCC used for simple derevations that don't need GCC or something like that
# Used by `font-awesome` and `unifont_upper`:
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/font-awesome/default.nix
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/un/unifont_upper/package.nix
stdenvNoCC.mkDerivation rec {
  pname = "UnifontEX";
  version = "16";

  # Decided to use `fetchurl` like here
  # https://github.com/nix-community/nur-combined/blob/main/repos/Dev380/pkgs/blobmoji/default.nix
  src = fetchurl {
    url = "https://github.com/stgiga/UnifontEX/releases/download/${version}/UnifontExMono.ttf";
    sha256 = "d2840072b230b46dde7a6156f6f45ed0dac37b1def2ce0fdbf88aaf7bb3f3352";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/fonts/unifontex/UnifontExMono.ttf
    runHook postInstall
  '';

  meta = {
    description = "An extended fork of GNU Unifont with a focus on high compatibility";
    # Idk what to write here
    # longDescription = ''
    # '';
    homepage = "https://stgiga.github.io/UnifontEX/sleek.htm";
    donationPage = "https://github.com/sponsors/stgiga";
    downloadPage = "https://github.com/stgiga/UnifontEX/releases";

    # Other 'Unifont' packages have the same license and since UnifontEX is
    # their fork I guess it's the same
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/un/unifont/package.nix
    license = with lib.licenses; [
      gpl2Plus
      fontException
    ];
    platforms = lib.platforms.all;
  };
}
