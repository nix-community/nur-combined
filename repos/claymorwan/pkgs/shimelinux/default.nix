{
  stdenv,
  lib,
  fetchFromGitHub,
  gradle,
  rustPlatform,
  cargo,
  makeWrapper,
  libappindicator,
  glib,
  jdk21,
  pkg-config,
  libxkbcommon,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shimelinux";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "BujjuIsABee";
    repo = "shimelinux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fAitO1fuqH+GyHW6sDiB8JlnF8qItysUcd3dklNKO9g=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper

    # For Wayland rust lib
    rustPlatform.cargoSetupHook
    cargo
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ];

  mitmCache = gradle.fetchDeps {
    # inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = "${finalAttrs.src}/shimelinux_wayland";
    hash = "sha256-AW0QtjC2qO4lTIFc7E58xwg1qybkL2sLIQQyVx4MYik=";
  };

  cargoRoot = "shimelinux_wayland";

  # __darwinAllowLocalNetworking = true;
  doCheck = true;
  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  prePatch = ''
    substituteInPlace ./shimelinux.sh \
      --replace-fail '/usr/share' "$out/share"

    substituteInPlace ./shimelinux.desktop \
      --replace-fail "/usr/bin/" ""
  '';

  installPhase = ''
    install -Dm644 build/libs/shimelinux-${finalAttrs.version}.jar $out/share/java/shimelinux.jar
    install -Dm755 ./shimelinux.sh $out/bin/shimelinux

    install -Dm644 ./icon.svg $out/share/icons/hicolor/scalable/apps/shimelinux.svg
    install -Dm644 ./shimelinux.desktop -t $out/share/applications

    wrapProgram $out/bin/shimelinux \
      --prefix PATH : ${lib.makeBinPath [ jdk21 ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libappindicator glib ]}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=v(\\d+\\.\\d+\\.\\d+)" ];
  };

  meta = {
    description = "An unofficial Linux port of Shimeji-ee Desktop Pet";
    homepage = "https://github.com/BujjuIsABee/shimelinux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ claymorwan ];
    mainProgram = "shimelinux";
    platforms = lib.platforms.linux;
    sourceProvenance =  with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})
