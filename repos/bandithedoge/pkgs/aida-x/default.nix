{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.aida-x) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
    python3
  ];

  buildInputs = with pkgs; [
    libGL
    xorg.libX11
  ];

  postPatch = ''
    patchShebangs modules/dpf/utils/res2c.py
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3,lib/vst}
    cp bin/AIDA-X $out/bin
    cp bin/AIDA-X.clap $out/lib/clap
    cp -r bin/AIDA-X.lv2 $out/lib/lv2
    cp -r bin/AIDA-X.vst3 $out/lib/vst3
    cp bin/AIDA-X-vst2.so $out/lib/vst/AIDA-X.so
  '';

  meta = with pkgs.lib; {
    description = "An Amp Model Player leveraging AI";
    homepage = "https://aida-x.cc/";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
