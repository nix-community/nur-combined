{
  maintainers,
  pkgs,
  ...
}: let
  pname = "waveql";
  version = "0.2.0";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "waveql";
    rev = "v${version}";
    hash = "sha256-zQth+TSif/ikj1748Kye7Pl86zLWAOZe1Z2S2UGHgrY=";
  };

  cargoHash = "sha256-Tf28s+CW5YqN7kNVh3t7mMBzGLh5ETONxESjgdeINdE=";

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
