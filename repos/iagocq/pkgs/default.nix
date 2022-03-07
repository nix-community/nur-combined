{ pkgs }:

let
  inherit (pkgs) callPackage lib;
in
{
  lightspeed-ingest = callPackage ./lightspeed-ingest { };
  lightspeed-react = callPackage ./lightspeed-react { };
  lightspeed-webrtc = callPackage ./lightspeed-webrtc { };
  parprouted = callPackage ./parprouted { };
  parsec = callPackage ./parsec { };
  telegram-send = callPackage ./telegram-send { };
  truckersmp-cli = callPackage ./truckersmp-cli { };

  pptpd = pkgs.pptpd.overrideAttrs (old: {
    configureFlags = [ "--enable-bcrelay" ];
    meta = old.meta // {
      description = old.meta.description + " (with bcrelay)";
    };
  });

  ultimmc =
    let
      src = pkgs.fetchFromGitHub {
        fetchSubmodules = true;
        owner = "AfoninZ";
        repo = "MultiMC5-Cracked";
        rev = "4afe2466fd5639bf8a03bfb866c070e705420d86";
        sha256 = "sha256-CLRXatiNbPv57LwT8fbOAlcRjMNISeaM5hLgL1ARF8Q=";
      };
      multimcPkg = pkgs.polymc or pkgs.multimc;
      description = "Cracked version of a popular Minecraft launcher";
      categories = if lib.versionAtLeast lib.version "22.05pre" then [ "Game" ] else "Game;";
    in
    multimcPkg.overrideAttrs (old: {
      inherit src;
      version = "0.6.14-custom";
      pname = "ultimmc";

      nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.copyDesktopItems ];
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "ultimmc";
          desktopName = "UltimMC";
          icon = "ultimmc";
          comment = description;
          exec = "UltimMC %u";
          inherit categories;
        })
      ];

      cmakeFlags = [ "-DLauncher_LAYOUT=lin-nodeps" ];

      postInstall =
        let
          libpath = with pkgs.xorg; pkgs.lib.makeLibraryPath [
            libX11
            libXext
            libXcursor
            libXrandr
            libXxf86vm
            pkgs.libpulseaudio
            pkgs.libGL
          ];
        in
        ''
          # nixpkgs/nixos-21.11 for some reason auto-wraps everything in /bin that is executable
          chmod -x $out/bin/*.so
          install -Dm0644 ${src}/notsecrets/logo.svg $out/share/icons/hicolor/scalable/apps/ultimmc.svg
          wrapProgram $out/bin/UltimMC \
            "''${qtWrapperArgs[@]}" \
            --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xorg.xrandr ]} \
            --add-flags '-d "$HOME/.local/share/ultimmc"'
          rm $out/UltimMC
        '';

      meta = with pkgs.lib; old.meta // {
        inherit description;
        homepage = "https://github.com/AfoninZ/MultiMC5-Cracked";
        maintainers = [ ];
        license = licenses.asl20;
      };
    });
}
