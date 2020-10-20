{ pkgs, stdenv, requireFile, autoPatchelfHook, squashfsTools, makeWrapper, zip
  , love_11 , luajit, mpg123
  , openal, libogg, freetype , libtheora, libvorbis, libmodplug }:

let

  version = "2020-04-11";

in stdenv.mkDerivation rec {
  pname = "hospital-hero";
  inherit version;

  src = requireFile {
    name = "hospital_hero-linux-x86_64.tar.gz";
    message = ''
      This nix expression requires that hospital_hero-linux-x86_64.tar.gz is
      already part of the store. Find the file on the website
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "1efc782bc07b0ec939b375ccca8472d0ce6cf6c36b8e35f2847e8adb3225a819";
  };

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc makeWrapper squashfsTools zip ];
  buildInputs = [ love_11 luajit mpg123 openal libogg freetype libtheora libvorbis libmodplug ];

  dontStrip = true;
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
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
    license = licenses.unfree;
    maintainers = with maintainers; [ genesis ];
    platforms = [ love_11.meta.platforms ];
  };
}
