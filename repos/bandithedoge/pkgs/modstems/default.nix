{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.modstems) pname src;
  version = sources.modstems.date;

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    libopenmpt.dev
  ];

  meta = with pkgs.lib; {
    description = "Dumps \"stems\" from module files using libopenmpt ";
    homepage = "https://github.com/bandithedoge/modstems";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
