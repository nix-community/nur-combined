{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  alsa-lib,
  fontconfig,
  libGL,
  libjack2,
  libx11,
  libxcb,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "open-mbc";
  version = "0.2.2";
  src = fetchFromGitHub {
    owner = "maor1993";
    repo = "open_mbc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z1eoaZeVW0PoxBEyASEAD25eTzf6DPwNf/cgiVfkFIA=";
  };

  cargoHash = "sha256-5gy3jIHJ9gknbJQliudILVpJpZHxssUoEAQFMex2NnI=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libjack2
    libx11
    libGL
    libxcb
    fontconfig
  ];

  installPhase = ''
    cargo xtask bundle open_mbc --release
    mkdir -p $out/{bin,lib/vst3}
    cp "target/bundled/Open Mbc" $out/bin
    cp -r "target/bundled/Open Mbc.vst3" $out/lib/vst3
  '';

  checkFlags = [
    "--skip=compressor::tests::run_compressor_ex002"
    "--skip=compressor::tests::run_compressor_ex003"
    "--skip=compressor::tests::run_compressor_ex004"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "multiband compressor vst";
    homepage = "https://github.com/maor1993/open_mbc";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "OpenMbc";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
