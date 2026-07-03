{
  maintainers,
  pkgs,
  ...
}: let
  pname = "waveql";
  version = "0.3.0";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "waveql";
    rev = "v${version}";
    hash = "sha256-Dm7s+Wro72R2IX3DOoN17fhwOiSUIBEX4t6r5tp97k8=";
  };

  cargoHash = "sha256-ro6jY/h2ZABh8RGyrYK+QEV8zLf8ChAvmrqAvcXqkRM=";

  meta = with pkgs.lib; {
    description = "A high-performance VCD/FST waveform query CLI for AI Agents and humans";
    homepage = "https://github.com/srcres258/waveql";
    license = licenses.mit;
    maintainers = with maintainers; [ srcres258 ];
    mainProgram = "waveql";
    platforms = platforms.linux ++ platforms.darwin;
    broken = versionOlder pkgs.rustc.version "1.90.0";
  };
}
