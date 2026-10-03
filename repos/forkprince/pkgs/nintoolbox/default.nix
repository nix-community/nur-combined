{
  autoPatchelfHook,
  stdenvNoCC,
  fetchurl,
  ncurses,
  openssl,
  libpng,
  stdenv,
  curl,
  zlib,
  lib,
}: let
  ver = lib.helper.read ./version.json;

  pname = "nintoolbox";
  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenvNoCC.hostPlatform.system ver);

  tools = [
    "ctrtool"
    "vgmtrans"
    "wbfsar"
    "wbmgt"
    "wbmsx"
    "wbrsar"
    "wbrstm"
    "wctct"
    "wimgt"
    "wkclt"
    "wkmpt"
    "wlayt"
    "wlect"
    "wmdlt"
    "wpatt"
    "wrbnk"
    "wseqt"
    "wstrt"
    "wszst"
    "wtest"
    "wwc24crypt"
  ];

  dataFiles = [
    "keys.txt"
    "prod.keys"
    "seeddb.bin"
    "title.keys"
  ];

  meta = {
    description = "Toolbox for Nintendo game file formats";
    homepage = "https://github.com/quatric/nintoolbox";
    maintainers = with lib.maintainers; [Prinky];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    mainProgram = "wszst";
  };
in
  stdenvNoCC.mkDerivation {
    inherit pname version src meta;

    sourceRoot = ".";

    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isLinux autoPatchelfHook;

    buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      stdenv.cc.cc.lib
      curl
      libpng
      ncurses
      openssl
      zlib
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      for tool in ${lib.concatStringsSep " " tools}; do
        install -Dm755 "$tool" $out/bin/"$tool"
      done

      for data in ${lib.concatStringsSep " " dataFiles}; do
        [ -f "$data" ] && install -Dm644 "$data" $out/bin/"$data"
      done

      if [ -d wiiu_keys ]; then
        cp -R wiiu_keys $out/bin/
      fi

      runHook postInstall
    '';
  }
