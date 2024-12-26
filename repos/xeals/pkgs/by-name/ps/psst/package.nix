{ lib
, fetchFromGitHub
, rustPlatform

, pkg-config
, alsa-lib
, dbus
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
  version = "20221012.d70ed81";
  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "d70ed8104533dc15bc36b989ba8428872c9b578f";
    hash = "sha256-ZKhHN0ruLb6ZVKkrKv/YawRsVop6SP1QF/nrtkmA8P8=";
    fetchSubmodules = true;
  };
  cargoSha256 = "sha256-zH6+EV78FDVOYEFXk0f54pH2Su0QpK1I0bHqzIiMdBo=";

  nativeBuildInputs = [ pkg-config ]
    ++ optional withGui copyDesktopItems;

  buildInputs = [ alsa-lib dbus openssl ]
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
