{ stdenv
, lib
, fetchFromGitHub
, rustPlatform

, cmake
, pkg-config
, openssl

  # GUI
, withGui ? true
, copyDesktopItems
, makeDesktopItem
, gtk3
}:

let
  inherit (lib) optional optionals;
in

assert withGui -> gtk3.meta.available;

rustPlatform.buildRustPackage rec {
  pname = "psst";
  version = "20210122.gec114ac";
  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "ec114ac8299179c8dd51bc026d6060dc75658b83";
    sha256 = "02mh6hjnlimadc3w899hccss31p1r4sxgb5880zwn7yiycbq3yyj";
    fetchSubmodules = true;
  };
  cargoSha256 = "1m01rycnpy9asspih1x9l5ppfbjnqcfdycmzgkrmdwzah3x8s8xc";

  nativeBuildInputs = [ pkg-config ]
    ++ optional withGui copyDesktopItems;

  buildInputs = [ openssl ]
    ++ optional withGui gtk3;

  cargoBuildFlags = optionals (!withGui) [
    "--workspace"
    "--exclude"
    "psst-gui"
  ];

  # Unable to exclude targets from the check phase as it doesn't respect
  # `cargoBuildFlags`; to save from attempting to build the GUI without meaning
  # to, don't bother checking for CLI-only builds.
  # https://github.com/NixOS/nixpkgs/blob/77d190f10931c1d06d87bf6d772bf65346c71777/pkgs/build-support/rust/default.nix#L241
  doCheck = withGui;

  desktopItems = optionals withGui [
    (makeDesktopItem {
      name = pname;
      desktopName = "psst";
      genericName = "Spotify Player";
      categories = [ "AudioVideo" "Audio" "Network" "Player" ];
      comment = "Spotify client with native GUI";
      exec = "psst-gui";
      keywords = [ "spotify" "music" ];
      icon = "spotify";
      type = "Application";
    })
  ];

  meta = with lib; {
    description = "Fast and multi-platform Spotify client with native GUI ";
    homepage = "https://github.com/jpochyla/psst";
    license = licenses.mit;
  };
}
