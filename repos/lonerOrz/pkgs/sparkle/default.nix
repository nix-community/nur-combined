{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  nss,
  nspr,
  alsa-lib,
  openssl,
  webkitgtk_4_1,
  udev,
  libayatana-appindicator,
  libGL,
  musl,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "sparkle";
  version = current.version;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/INKCR0W/sparkle/releases/download/${version}/sparkle-linux-${version}-${{
      x86_64-linux = "amd64";
      aarch64-linux = "arm64";
    }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")}.deb";
    hash = current.${stdenv.hostPlatform.system + "-hash"};
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  buildInputs = [
    musl
    nss
    nspr
    alsa-lib
    openssl
    webkitgtk_4_1
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out/opt
    cp -r usr/share $out/share
    substituteInPlace $out/share/applications/sparkle.desktop \
      --replace-fail "/opt/sparkle/sparkle" "sparkle"
    ln -s $out/opt/sparkle/sparkle $out/bin/sparkle
  '';

  preFixup = ''
    patchelf --add-needed libGL.so.1 \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
          udev
          libayatana-appindicator
        ]
      } $out/opt/sparkle/sparkle
  '';

  passthru.updateScript =
    let
      versionFile = "pkgs/sparkle/version.json";
    in
    callPackage ../../utils/update.nix {
      inherit versionFile;
      pname = "sparkle";
      updateMethod = "none";
      fetchMetaCommand = "${lib.getExe (
        callPackage ../../utils/fetch-urls.nix {
          inherit versionFile;
          versionCommand = ''
            curl -sS https://api.github.com/repos/INKCR0W/sparkle/releases/latest \
              | jq -r '.tag_name'
          '';
          hashUrls = {
            x86_64-linux = "https://github.com/INKCR0W/sparkle/releases/download/$VERSION/sparkle-linux-$VERSION-amd64.deb";
            aarch64-linux = "https://github.com/INKCR0W/sparkle/releases/download/$VERSION/sparkle-linux-$VERSION-arm64.deb";
          };
        }
      )}";
    };

  meta = {
    description = "Another Mihomo GUI";
    homepage = "https://github.com/INKCR0W/sparkle";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "sparkle";
  };
}
