{ lib, rustPlatform, fetchFromGitHub
, pkg-config, python3
, libGL, libX11, libxcb, libXcursor, xcbutilwm }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "octasine";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "greatest-ape";
    repo = "OctaSine";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Vr1L5B7dF0pJieE/Zww/T6XbZadWMK5Fdq66qRfQFF0=";
  };

  cargoHash = "sha256-I+iZxngM8o4BIzjpowjf8l2m6MSY/NSSOd4TcYFjrIc=";

  buildPhase = ''
    runHook preBuild
    cargo xtask bundle -p octasine --release --features "clap,vst2"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vst $out/lib/clap
    cp target/bundled/octasine.so $out/lib/vst/OctaSine.so
    cp target/bundled/octasine.clap $out/lib/clap/OctaSine.clap
    runHook postInstall
  '';

  buildInputs = [
    libGL
    libX11
    libxcb
    libXcursor
    xcbutilwm
  ];
  nativeBuildInputs = [ pkg-config python3 ];

  meta = {
    description = "A four-operator stereo FM synthesizer CLAP/VST2 plugins";
    homepage = "https://www.octasine.com/";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.suhr ];
  };
})
