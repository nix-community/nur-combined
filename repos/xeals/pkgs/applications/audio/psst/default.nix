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
  version = "20210114.1fadc78";
  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "1fadc78912af4d52e5e20e60e185f8e3ddcfc82e";
    sha256 = "1dvsxd3rica8sm9nlx14vh37wb9aclsz33ahklcfga7w0w8l4zzr";
    fetchSubmodules = true;
  };
  cargoSha256 = "05miwyjyd9zjcxw3aws0xcv1jgmy0md8pa6vljg8wiqgknjxcw56";

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
