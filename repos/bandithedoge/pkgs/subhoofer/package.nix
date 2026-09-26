{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  libGL,
  libx11,
  libxcb,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "subhoofer";
  version = "2.2.3";
  src = fetchFromGitHub {
    owner = "ardura";
    repo = "subhoofer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ArGOyyuZaRg4lI+hV3JHJRUSkMpad9v1tq64lf/ilmw=";
  };

  cargoHash = "sha256-iUWPE1cDaXg4HLz7GCJb7qfTDKE9XL8kTq4oqV9euv0=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libGL
    libx11
    libxcb
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,vst3}
    cargo xtask bundle Subhoofer --profile release
    cp target/bundled/Subhoofer.clap $out/lib/clap
    cp -r target/bundled/Subhoofer.vst3 $out/lib/vst3

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sub and Bass Enhancement plugin";
    homepage = "https://github.com/ardura/Subhoofer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
