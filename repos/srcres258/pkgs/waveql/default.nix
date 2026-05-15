{
  maintainers,
  pkgs,
  ...
}: let
  pname = "waveql";
  version = "0.1.0";
in pkgs.rustPlatform.buildRustPackage {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "srcres258";
    repo = "waveql";
    rev = "v${version}";
    hash = "sha256-WkZ1IsD6kAxVJI/DKipwwWVSv8v1Dz+nvExIfDZEJRo=";
  };

  cargoHash = "sha256-RKl4OXLy/r7wKPBqgQscGx03o/yt0rkYvyxo0TNXTao=";

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
