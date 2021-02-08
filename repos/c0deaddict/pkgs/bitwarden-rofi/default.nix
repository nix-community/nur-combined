# source: https://github.com/kylesferrazza/nix/blob/288edcd1d34884b9b7083c6d718fbe10febe0623/overlay/bitwarden-rofi.nix
# TODO https://github.com/mattydebie/bitwarden-rofi/issues/34

{ lib, stdenv, fetchFromGitHub, makeWrapper, unixtools, xsel, xclip
, wl-clipboard, xdotool, bitwarden-cli, rofi, jq, keyutils }:
let
  bins = [
    jq
    bitwarden-cli
    unixtools.getopt
    rofi
    xsel
    xclip
    # wl-clipboard
    xdotool
    keyutils
  ];
in stdenv.mkDerivation {
  pname = "bitwarden-rofi";
  version = "git-2019-11-08";

  src = fetchFromGitHub {
    owner = "mattydebie";
    repo = "bitwarden-rofi";
    rev = "74ba37397f8b89105e46b33667ac9a26ddd51f70";
    sha256 = "1yy716y8jfqpm2s3h4abq1jnl4rvnd323wqxsrcbw154n0470418";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    install -Dm755 "bwmenu" "$out/bin/bwmenu"
    install -Dm755 "lib-bwmenu" "$out/bin/lib-bwmenu" # TODO don't put this in bin

    install -Dm755 -d "$out/usr/share/doc/bitwarden-rofi"
    install -Dm755 -d "$out/usr/share/doc/bitwarden-rofi/img"

    install -Dm644 "README.md" "$out/usr/share/doc/bitwarden-rofi/README.md"
    install -Dm644 img/* "$out/usr/share/doc/bitwarden-rofi/img/"

    wrapProgram "$out/bin/bwmenu" --prefix PATH : ${lib.makeBinPath bins}
  '';

  meta = with lib; {
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = "https://github.com/mattydebie/bitwarden-rofi";
    maintainers = with maintainers; [ kylesferrazza ];
  };

}
