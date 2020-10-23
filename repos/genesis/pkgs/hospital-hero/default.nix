{ pkgs, stdenv, requireFile, squashfsTools, makeWrapper, love_11 }:

let

  version = "2020-04-11";

in stdenv.mkDerivation rec {
  pname = "hospital-hero";
  inherit version;

  src = requireFile {
    name = "hospital_hero-linux-x86_64.tar.gz";
    message = ''
      This nix expression requires that hospital_hero-linux-x86_64.tar.gz is
      already part of the store. Find the file on ${meta.downloadPage}
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "1efc782bc07b0ec939b375ccca8472d0ce6cf6c36b8e35f2847e8adb3225a819";
  };

  nativeBuildInputs = [ makeWrapper squashfsTools ];
  buildInputs = [ love_11 ];

  phases = [ "unpackPhase" "installPhase" ];
  sourceRoot = ".";
  installPhase = ''
    # file header are not good for appimageTools, use binwalk to get the offset
    unsquashfs -q -d . -f -o 188392 Hospital_Hero-x86_64.AppImage
    install -Dm755 ./hospital_hero.love $out/share/games/lovegames/${pname}.love
    makeWrapper ${love_11}/bin/love $out/bin/${pname} --add-flags $out/share/games/lovegames/${pname}.love
  '';

meta = with stdenv.lib; {
    description = "You are a 101% systemically relevant janitor-hero!";
    homepage = https://hackefuffel.itch.io/hospital-hero;
    downloadPage = meta.homepage;
    license = licenses.unfree;
    maintainers = with maintainers; [ genesis ];
    platforms = [ love_11.meta.platforms ];
  };
}
