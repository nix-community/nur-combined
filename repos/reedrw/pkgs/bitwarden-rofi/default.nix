# source: https://github.com/kylesferrazza/nix/blob/288edcd1d34884b9b7083c6d718fbe10febe0623/overlay/bitwarden-rofi.nix
# TODO https://github.com/mattydebie/bitwarden-rofi/issues/34

{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, unixtools
, xsel
, xclip
, wl-clipboard
, xdotool
, bitwarden-cli
, rofi
, jq
, keyutils
, libnotify
}:
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
    libnotify
  ];
in
stdenv.mkDerivation {
  pname = "bitwarden-rofi";
  version = "git-2022-05-02";

  src = fetchFromGitHub {
    owner = "mattydebie";
    repo = "bitwarden-rofi";
    rev = "732aa060ca04442cc16de43a7144ba817cda7f95";
    sha256 = "sha256-AHoKU1J43K41eYeHopdMi6p4cro3f6I7TUrX2xjPbHc=";
  };

  buildInputs = [
    makeWrapper
  ];

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
    description = "Wrapper for Bitwarden and Rofi";
    homepage = "https://github.com/mattydebie/bitwarden-rofi";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };

}
