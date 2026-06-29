{
  lib,
  stdenv,
  stdenvNoCC,
  fetchzip,
  fetchFromGitHub,
  cmake,
  ninja,
  git,
  SDL2,
  libpng,
  libjpeg,
  libglvnd,
  bashInteractive,
  makeDesktopItem,
  makeWrapper,
}:

let
  fullVersion = "1.3.7.3-1";
  versionNoHotfix = builtins.concatStringsSep "." (lib.take 4 (lib.splitVersion fullVersion));
  thextech = stdenv.mkDerivation rec {
    pname = "thextech";
    version = fullVersion;

    src = fetchzip {
      url = "https://github.com/TheXTech/TheXTech/releases/download/v${versionNoHotfix}/thextech-full-src-v${versionNoHotfix}.tar.bz2";
      hash = "sha256-8w2H9g3QDRgsRRcMqQjB72tMKQ52J8MMvmqc1Up5G8w=";
    };
    #src = fetchFromGitHub {
    #  owner = "TheXTech";
    #  repo = "TheXTech";
    #  rev = "v${version}";
    #  hash = "sha256-ZRvaaETrf5Bd5/lassk/h3BKULoAO+tHyp3MTpYLq24=";
    #  fetchSubmodules = true;
    #  leaveDotGit = true;
    #};

    passthru.versionNoHotfix = versionNoHotfix;

    buildInputs = [
      SDL2
      libpng
      libjpeg
      libglvnd
    ];

    nativeBuildInputs = [
      cmake
      ninja
      git
    ];

    preBuild = ''
      mkdir -p output/lib
      ln -s $PWD/output/lib output/lib64
    '';

    preFixup =
      if stdenv.isDarwin then
        ''
          mkdir $out/Applications
          mv $out/TheXTech.app $out/Applications/TheXTech.app
        ''
      else
        ''
          rm -r $out/TheXTech
          mkdir $out/lib
          cp output/lib/*.so* $out/lib
        '';

    # this was designed mainly for SMBX, if other packs do something different, it may break
    passthru.wrapGame =
      {
        # examples are in comments
        packId, # smbx
        gameName, # Super Mario Bros. X
        gameDir, # smbx13
        gameSrc, # (the directory to the game assets)
        gameVersion ? version,
        desktopGenericName ? "", # SMBX
        desktopComment ? "", # The Mario fan-game originally created by Andrew Spinks also known as a creator of the Terraria game.
        meta ? null,
      }:
      let
        executable = "thextech-${packId}";
        desktopItem = makeDesktopItem {
          name = executable;
          desktopName = gameName;
          exec = "${executable} @F";
          icon = gameDir;
          comment = desktopComment;
          genericName = desktopGenericName;
          #encoding = "UTF-8";
          #version = "1.0";
          type = "Application";
          categories = [ "Game" ];
          terminal = false;
          startupWMClass = "TheXTech";
        };
      in
      stdenvNoCC.mkDerivation {
        inherit meta;
        pname = executable;
        version = gameVersion;

        # TODO: make this support directories
        src = gameSrc;

        nativeBuildInputs = lib.optional stdenvNoCC.isDarwin makeWrapper;

        # TODO: update Info.plist (probably with PlistBuddy)
        # TODO; figure out why it's not loading assets from this location
        installPhase =
          if stdenvNoCC.isDarwin then
            ''
              appDir="$out/Applications/${gameName}.app"
              echo $appDir
              mkdir -p $out/Applications
              cp -r ${thextech}/Applications/TheXTech.app "$appDir"
              # work around permission issue
              chmod -R +w "$appDir"
              cp -r $src "$appDir/Contents/Resources/assets"
              wrapProgram "$appDir/Contents/MacOS/TheXTech" \
                --add-flags "-c \"$appDir/Contents/Resources/assets\""
            ''
          else
            ''
              mkdir -p $out/bin $out/share/{applications,icons}
              cp ${desktopItem}/share/applications/*.desktop $out/share/applications

              for f in 16 32 48 128 256; do
                i=$src/graphics/ui/icon/thextech_$f.png
                if test -e $i; then
                  d=$out/share/icons/hicolor/''${f}x''${f}/apps
                  mkdir -p $d
                  cp $i $d/${gameDir}.png
                fi
              done

              cp ${./wrapper.sh} $out/bin/${executable}
              substituteInPlace $out/bin/${executable} \
                --replace-fail NIXBASH ${bashInteractive}/bin/bash \
                --replace-fail NIXPACKID ${packId} \
                --replace-fail NIXGAMEDIR $src \
                --replace-fail NIXGAMENAME "${gameName}" \
                --replace-fail NIXBINARYPATH "${thextech}/bin/thextech"
              chmod +x $out/bin/${executable}
            '';
      };

    meta = with lib; {
      description = "The full port of the SMBX engine from VB6 into C++ and SDL2, FreeImage and MixerX";
      homepage = "https://wohlsoft.ru/projects/TheXTech/";
      license = licenses.gpl3Plus;
      platforms = platforms.all;
      mainProgram = "thextech";
    };
  };
in
if stdenv.isDarwin then
  lib.warn "macOS implementation is incomplete, but the game launches" thextech
else
  thextech
