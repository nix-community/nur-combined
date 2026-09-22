{
  autoPatchelfHook,
  vulkan-loader,
  libxkbcommon,
  makeWrapper,
  fontconfig,
  stdenvNoCC,
  libxcursor,
  libxrandr,
  libxfixes,
  fetchurl,
  freetype,
  wayland,
  libdrm,
  libx11,
  libxcb,
  libxi,
  libGL,
  dbus,
  mesa,
  lib
}: let
  ver = lib.helper.read ./version.json;

  inherit (ver) version;

  src = fetchurl (lib.helper.getSingle ver);
in
  stdenvNoCC.mkDerivation rec {
    pname = "xuan";
    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      vulkan-loader
      libxkbcommon
      fontconfig
      libxcursor
      libxrandr
      libxfixes
      freetype
      wayland
      libdrm
      libx11
      libxcb
      libGL
      libxi
      dbus
      mesa
    ];

    sourceRoot = ".";
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      archive=$(echo xuan-*-linux-*)
      install -Dm755 "$archive/bin/xuan" -t $out/bin

      if [ -d "$archive/share" ]; then
        cp -r "$archive/share" $out/share
      fi

      wrapProgram $out/bin/xuan \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      runHook postInstall
    '';

    meta = {
      description = "An image editor for Linux, inspired by Compositor and ported from it.";
      homepage = "https://github.com/silverling/xuan";
      changelog = "https://github.com/silverling/xuan/releases/tag/v${version}";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      maintainers = with lib.maintainers; [Prinky];
      mainProgram = "xuan";
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
