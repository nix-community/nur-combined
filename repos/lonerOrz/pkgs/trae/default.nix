{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  binutils,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  xz,
  callPackage,

  # Hardened electron build inputs
  glib,
  gtk3,
  gdk-pixbuf,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  pango,
  nss,
  nspr,
  cups,
  curl,
  dbus,
  expat,
  fontconfig,
  freetype,
  libdrm,
  mesa,
  alsa-lib,
  libpulseaudio,
  libGL,
  libgbm,
  zlib,
  libgcrypt,
  libkrb5,
  udev,
  libxkbcommon,
  libxkbfile,
  libxcb,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXScrnSaver,
  libXtst,
  xcbutilwm,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  vulkan-loader,
  webkitgtk_4_1,
  libsoup_3,
  libsecret,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "trae";
  version = current.version;
  buildId = current.buildId;

  baseUrl = "https://lf-cdn.trae.ai/obj/trae-ai-us/pkg/app/releases/stable";

  architectures = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
  };

  system = stdenv.hostPlatform.system;

  # Generate download URL for a given system and version.
  debUrl =
    system: buildId:
    let
      arch = architectures.${system} or (throw "trae: unsupported system: ${system}");
    in
    "${baseUrl}/${buildId}/linux/TRAE-linux-${arch}.deb";

  src = fetchurl {
    url = debUrl system buildId;
    hash = current.${system + "-hash"};
  };

  runtimeLibs = [
    glib.out
    gtk3.out
    gdk-pixbuf
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    pango
    nss
    nspr
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    libdrm
    mesa
    alsa-lib
    libpulseaudio
    libGL
    libgbm
    zlib
    libkrb5
    udev
    libxkbcommon
    libxkbfile
    libxcb
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXScrnSaver
    libXtst
    xcbutilwm
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    vulkan-loader
    libgcrypt.lib
    webkitgtk_4_1
    libsoup_3
    libsecret
    stdenv.cc.cc.lib
  ];
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    binutils
    copyDesktopItems
    dpkg
    makeWrapper
    xz
  ];

  buildInputs = runtimeLibs;

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
    "libwebkit2gtk-4.1.so.0"
    "libsoup-3.0.so.0"
    "libsecret-1.so.0"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "trae";
      desktopName = "Trae";
      genericName = "Text Editor";
      comment = "Code Editing. Redefined.";
      exec = "trae %F";
      icon = "trae";
      terminal = false;
      startupNotify = false;
      startupWMClass = "Trae";
      categories = [
        "TextEditor"
        "Development"
        "IDE"
      ];
      mimeTypes = [
        "application/x-trae-workspace"
      ];
      keywords = [
        "trae"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    # Extract deb manually - dpkg -x fails on chrome-sandbox setuid bit
    mkdir -p ./extracted
    (
      cd ./extracted
      ar x $src
      if [ -f data.tar.xz ]; then
        tar xf data.tar.xz --no-same-permissions
      elif [ -f data.tar.gz ]; then
        tar xf data.tar.gz --no-same-permissions
      elif [ -f data.tar.zst ]; then
        tar --use-compress-program=unzstd -xf data.tar.zst --no-same-permissions
      else
        echo "ERROR: unknown data.tar format"
        ls -la
        exit 1
      fi
    )

    mkdir -p $out/share
    mv ./extracted/usr/share/trae $out/share/trae
    mv ./extracted/usr/share/pixmaps $out/share/pixmaps
    mv ./extracted/usr/share/appdata $out/share/appdata 2>/dev/null || true
    mv ./extracted/usr/share/bash-completion $out/share/bash-completion 2>/dev/null || true
    mv ./extracted/usr/share/mime $out/share/mime 2>/dev/null || true

    mkdir -p $out/bin
    makeWrapper $out/share/trae/bin/trae $out/bin/trae \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
      --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}

    runHook postInstall
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/trae/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "trae";
      updateMethod = "none";
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/fetch-urls.nix {
          inherit versionFile;
          templateCommands = {
            VERSION = ''
              curl -fsSL \
                --retry 3 \
                --retry-all-errors \
                "https://icube-normal.trae.ai/icube/api/v1/native/version/trae/latest" |
                jq -er '
                  [
                    .data.manifest.linux.versions[]
                    | select(.region == "va")
                    | .version
                  ]
                  | unique
                  | if length == 1 then .[0]
                    else error("Expected exactly one VERSION")
                    end
                '
            '';

            BUILDID = {
              json.key = "buildId";

              command = ''
                curl -fsSL \
                  --retry 3 \
                  --retry-all-errors \
                  "https://icube-normal.trae.ai/icube/api/v1/native/version/trae/latest" |
                  jq -er '
                    [
                      .data.manifest.linux.versions[]
                      | select(.region == "va")
                      | .url
                      | capture("/stable/(?<build>[^/]+)/linux/").build
                    ]
                    | unique
                    | if length == 1 then .[0]
                      else error("Expected exactly one BUILDID")
                      end
                  '
              '';
            };
          };

          hashUrls = lib.mapAttrs (system: _arch: debUrl system "@BUILDID@") architectures;
        }
      )}";
    };

  meta = {
    description = "Trae - AI-powered IDE by ByteDance";
    homepage = "https://www.trae.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames architectures;
    mainProgram = "trae";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
