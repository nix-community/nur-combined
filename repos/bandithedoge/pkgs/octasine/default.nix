{
  pkgs,
  sources,
  ...
}:
pkgs.rustPlatform.buildRustPackage {
  inherit (sources.octasine) pname version src;
  cargoLock = sources.octasine.cargoLock."Cargo.lock";

  nativeBuildInputs = with pkgs; [
    pkg-config
    python3
  ];

  buildInputs = with pkgs; [
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libxcb
    xorg.xcbutilwm
  ];

  meta = with pkgs.lib; {
    description = "Frequency modulation synthesizer plugin (VST2, CLAP).";
    homepage = "https://www.octasine.com/";
    license = licenses.agpl3;
  };
}
