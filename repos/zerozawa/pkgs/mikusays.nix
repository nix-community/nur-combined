{
  fetchFromGitHub,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "mikusays";
  version = "0.1.4-2";
  src = fetchFromGitHub {
    owner = "xxanqw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4cvukP+XUsnnNHrNdwlbsqDfaaJJObWV4hbEFAytqi0=";
  };

  postPatch = ''
    substituteInPlace tests/integration_tests.rs \
      --replace-fail 'Command::new("target/debug/mikusays")' 'Command::new(env!("CARGO_BIN_EXE_mikusays"))'

    # 在 main.rs 开头添加 feature flag
    sed -i '1i #![feature(let_chains)]' src/main.rs
  '';

  cargoHash = "sha256-3u5zmn3QAFDhgZmJTxL3FSnNQSxATtwXiTGOG3F8FVQ=";

  RUSTC_BOOTSTRAP = 1;

  meta = with lib; {
    description = "A `cowsay` clone with Hatsune Miku ASCII art and speech bubbles.";
    homepage = "https://github.com/xxanqw/mikusays";
    platforms = with platforms; (windows ++ linux ++ darwin);
    license = with licenses; [mit];
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [fromSource];
  };
})
