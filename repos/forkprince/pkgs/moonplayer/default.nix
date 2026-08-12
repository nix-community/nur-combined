{
  fetchFromGitHub,
  fetchurl,
  python3,
  stdenv,
  ffmpeg,
  cmake,
  unzip,
  wget,
  curl,
  mpv,
  qt6,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "moonplayer";

  base = {
    description = "Video player that can play online videos from YouTube, Bilibili etc";
    homepage = "https://github.com/coslyk/moonplayer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [Prinky];
    mainProgram = "moonplayer";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
in
  if stdenv.isDarwin
  then
    stdenv.mkDerivation (lib.helper.mkDarwin {
      inherit pname;
      inherit (ver) version;

      src = fetchurl (lib.helper.getSingle ver);

      nativeBuildInputs = [unzip];

      meta =
        base
        // {
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
        };
    })
  else
    stdenv.mkDerivation rec {
      inherit pname;

      meta =
        base
        // {
          sourceProvenance = [lib.sourceTypes.fromSource];
        };

      version = "4.3";

      src = fetchFromGitHub {
        owner = "coslyk";
        repo = "moonplayer";
        rev = "v${version}";
        hash = "sha256-SckSTwGcnTItd9M3fkzsCdg6Ocv/CtXBxVi08CW4l/c=";
        fetchSubmodules = true;
      };

      patches = [./moonplayer-gui-private.patch];

      nativeBuildInputs = [
        qt6.wrapQtAppsHook
        cmake
      ];

      buildInputs = [
        qt6.qtdeclarative
        qt6.qttools
        qt6.qtbase
        python3
        ffmpeg
        wget
        curl
        mpv
      ];

      cmakeFlags = [
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        "-DCMAKE_PREFIX_PATH=${qt6.qtbase}"
      ];
    }
