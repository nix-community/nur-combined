# Shared builder for the storytold Craft App Suite releases.
#
# Every app publishes identical tarballs:
#   <app>-<version>-linux-<arch>.tar.gz containing <app>-<version>-linux-<arch>/{bin,share}
# with share/ already following the freedesktop layout and a SHA256SUMS.txt
# per release. App pins live in ./<app>/sources.nix.
{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dbus,
  alsa-lib,
  fontconfig,
  libglvnd,
  libX11,
  libXcursor,
  libXi,
  libxcb,
  libxkbcommon,
  vulkan-loader,
  wayland,
}: app: let
  inherit (app) pname description homepage;
  sources = import ./${app.upstream}/sources.nix;
  version = sources.version;
  hashes = sources;

  src =
    if stdenvNoCC.hostPlatform.system == "x86_64-linux"
    then
      fetchurl {
        url = "https://github.com/storytold/${app.upstream}/releases/download/v${version}/${app.upstream}-${version}-linux-x86_64.tar.gz";
        sha256 = hashes.x86_64-linux;
      }
    else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
    then
      fetchurl {
        url = "https://github.com/storytold/${app.upstream}/releases/download/v${version}/${app.upstream}-${version}-linux-aarch64.tar.gz";
        sha256 = hashes.aarch64-linux;
      }
    else throw "Unsupported system for ${pname}: ${stdenvNoCC.hostPlatform.system}";

  # Mirrors the upstream Arch depends lists: the pure-Rust winit/wgpu
  # binaries dlopen() the windowing, GPU and session libraries at runtime,
  # so they must be on LD_LIBRARY_PATH, not just in buildInputs.
  runtimeLibs = [
    alsa-lib # cpal audio playback dlopens libasound.so.2 (soundcraft, filmcraft, effectcraft, deckcraft)
    dbus
    fontconfig
    libglvnd
    libX11
    libXcursor
    libXi
    libxcb
    libxkbcommon
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];
in
  stdenvNoCC.mkDerivation {
    inherit pname version src description homepage;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = runtimeLibs;

    # The release tarball has a single top-level directory:
    # <upstream>-<version>-linux-<arch>/{bin,share}
    sourceRoot = "${app.upstream}-${version}-linux-${stdenvNoCC.hostPlatform.parsed.cpu.name}";

    installPhase = ''
      runHook preInstall

      install -d "$out/bin" "$out/lib/${pname}" "$out/share"

      # GUI binary plus the headless CLI companion every app ships.
      install -Dm755 "bin/${app.upstream}" "$out/lib/${pname}/${app.upstream}"
      if [ -f "bin/${app.upstream}-cli" ]; then
        install -Dm755 "bin/${app.upstream}-cli" "$out/lib/${pname}/${app.upstream}-cli"
      fi

      # share/ follows the freedesktop layout (applications, icons, mime,
      # metainfo, doc); its Exec lines point at the unwrapped binary name,
      # which the wrappers below provide.
      cp -r "share/." "$out/share/"

      for exe in "$out/lib/${pname}"/*; do
        name=$(basename "$exe")
        makeWrapper "$exe" "$out/bin/$name" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      done

      runHook postInstall
    '';

    meta = {
      inherit description homepage;
      license = with lib.licenses; [mit asl20];
      mainProgram = app.upstream;
      platforms = ["x86_64-linux" "aarch64-linux"];
      maintainers = [];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
