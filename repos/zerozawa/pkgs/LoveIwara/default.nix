{
  lib,
  flutter347,
  fetchFromGitHub,
  imagemagick,
  stdenvNoCC,
  xdg-utils,
  writeScript,
  alsa-lib,
  libdisplay-info,
  libepoxy,
  libnotify,
  libxpresent,
  libxscrnsaver,
  mpv-unwrapped,
  sqlite,
}:

flutter347.buildFlutterApplication (finalAttrs: {
  pname = "loveiwara";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "FoxSensei001";
    repo = "LoveIwara";
    tag = finalAttrs.version;
    hash = "sha256-9LKPAnMn/3XK+rLng+Fy0OGYsp2F3EJt9ppm59VcrBk=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  customSourceBuilders.sqlite3 =
    { version, src, ... }:
    stdenvNoCC.mkDerivation {
      pname = "sqlite3";
      inherit version src;
      inherit (src) passthru;

      setupHook = writeScript "sqlite3-setup-hook" ''
        sqliteFixupHook() {
          runtimeDependencies+=('${lib.getLib sqlite}')
        }

        preFixupHooks+=(sqliteFixupHook)
      '';

      postPatch = ''
        substituteInPlace lib/src/hook/compile/description.dart \
          --replace-fail \
          'return fromGitHub(LibraryType.sqlite3);' \
          "return LookupSystem('sqlite3');"
      '';

      installPhase = ''
        runHook preInstall

        cp -r . "$out"

        runHook postInstall
      '';
    };

  customSourceBuilders.sqlite3_flutter_libs =
    { version, src, ... }:
    stdenvNoCC.mkDerivation {
      pname = "sqlite3_flutter_libs";
      inherit version src;
      inherit (src) passthru;

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        cp -r . "$out"

        runHook postInstall
      '';
    };

  buildInputs = [
    alsa-lib
    libdisplay-info
    libepoxy
    libnotify
    libxpresent
    libxscrnsaver
    mpv-unwrapped
    sqlite
  ];
  nativeBuildInputs = [ imagemagick ];

  runtimeDependencies = [ mpv-unwrapped ];

  postPatch = ''
    substituteInPlace pubspec.yaml \
      --replace-fail 'version: 0.5.0+3' 'version: ${finalAttrs.version}+3' \
      --replace-fail '  flutter: 3.47.0' '  flutter: ">=3.47.0 <4.0.0"'
  '';

  env.CXXFLAGS = toString [ "-Wno-deprecated-literal-operator" ];

  postInstall = ''
    install -Dm644 linux/i_iwara.desktop \
      $out/share/applications/i_iwara.desktop
    substituteInPlace $out/share/applications/i_iwara.desktop \
      --replace-fail 'Name=i_iwara' 'Name=Love Iwara' \
      --replace-fail 'Comment=i_iwara video player' \
        'Comment=Cross-platform third-party Iwara client'
    install -Dm644 assets/icon/launcher_icon_v2.png \
      $out/share/icons/hicolor/256x256/apps/i_iwara.png
    ${imagemagick}/bin/convert \
      $out/share/icons/hicolor/256x256/apps/i_iwara.png \
      -resize 256x256 \
      $out/share/icons/hicolor/256x256/apps/i_iwara.png
  '';

  extraWrapProgramArgs = ''
    --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
    --prefix LD_LIBRARY_PATH : $out/app/loveiwara/lib
  '';

  meta = {
    description = "A fast, beautiful, cross-platform third-party Iwara client built with Flutter.";
    homepage = "https://github.com/FoxSensei001/LoveIwara";
    changelog = "https://github.com/FoxSensei001/LoveIwara/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "i_iwara";
    platforms = lib.platforms.linux;
  };
})
