{ stdenv
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
  inherit (stdenv.lib) optional optionals;
in

assert withGui -> gtk3.meta.available;

rustPlatform.buildRustPackage rec {
  pname = "psst";
  version = "20210103.002c2bb";
  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "002c2bbd610ab7a49b095cd871c56bfe2c3a9f6b";
    sha256 = "883ecb0ae2ef5af441dc4fe15ef15a2077f2cef10ab3e96096c38355acdba031";
    fetchSubmodules = true;
  };
  cargoSha256 = "e3f94e41fda9e2bc55b48ee77487d574d35e771fbd13a565432f30cda26654a1";

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
      categories = "AudioVideo;Audio;Network;Player;";
      comment = "Spotify client with native GUI";
      exec = "psst-gui";
      extraEntries = "Keywords=spotify;music;";
      icon = "spotify";
      type = "Application";
    })
  ];

  meta = with stdenv.lib; {
    description = "Fast and multi-platform Spotify client with native GUI ";
    homepage = "https://github.com/jpochyla/psst";
    license = licenses.mit;
  };
}
