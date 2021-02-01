{fetchurl, stdenv, autoPatchelfHook, makeDesktopItem, writeScriptBin,
 gcc-unwrapped, SDL2, SDL2_image, SDL2_mixer, SDL2_net,
}:
let version = "3.62";
    system = stdenv.hostPlatform.system;
in
  stdenv.mkDerivation {
    pname = "unreal_world";
    inherit version;
    src = fetchurl {
      url = "https://www.unrealworld.fi/dl/${version}/linux/deb-ubuntu/urw-${version}-${system}-gnu.tar.gz";
      sha256 =
        if system == "i686-linux" then
          "13k7qvlcgklj0s86yn5hz7p6j8jgl78bd43qjl4im7574rqg5gj2"
        else if system == "x86_64-linux" then
          "95f21bafc3c64c52b3c3251637452ff2c3fd257a723b7ebcfbfe5a8ac6bb9ed6"
        else
          throw "Unsupported platform ${system}";
    };

    buildInputs = [
      autoPatchelfHook
    ];

    runtimeDependencies = [
      gcc-unwrapped.lib
      SDL2
      SDL2_image
      SDL2_mixer
      SDL2_net
    ];

    patches = [
      ./launcher.patch
      ./desktop.patch
    ];

    installPhase = ''
      # .desktop file
      mkdir -p -- "$out/share/applications"
      substituteAllInPlace ubuntu/urw.desktop
      rm ubuntu/urw.desktop.orig
      mv ubuntu/urw.desktop "$out/share/applications"

      # icons
      mkdir -p -- "$out/share/icons/hicolor"
      find ubuntu/pixmaps -type f -print0 | while IFS= read -r -d $'\0' file;
      do
        if resolution="$(grep -Po '(?<=-)\d+(?=\.png$)' <<<"$file")"
        then
          target="$out/share/icons/hicolor/$resolution/apps"
          mkdir -p -- "$target"
          mv -- "$file" "$target/urwicon.png"
        fi
      done
      rmdir ubuntu/pixmaps

      # launcher
      substituteAllInPlace "ubuntu/urw"
      mkdir -p -- "$out/bin"
      mv -- ubuntu/urw "$out/bin/urw"
      chmod a=rx "$out/bin/urw"

      rmdir ubuntu

      # and then the rest
      mkdir -p -- "$out/share/unreal-world"
      mv --target-directory="$out/share/unreal-world" -- ./*
    '';

    meta = {
      description = "Survival based roguelike game";
      longDescription = "A unique low-fantasy roguelike game set in the far north during the late Iron-Age. The world of the game is highly realistic, rich with historical atmosphere and emphasized on survival in the harsh ancient wilderness. This package contains the latest free (in terms of cost) version of UnReal World, though there may be more recent releases available on itch.io and Steam";
      homepage = "https://unrealworld.fi";
      license = stdenv.lib.licenses.unfree;
      maintainers = with stdenv.lib.maintainers; [ ];
      platforms = [ "x86_64-linux" "i686-linux" ];
    };
  }
