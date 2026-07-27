{
  sources,

  lib,
  stdenv,

  cmake,
  libGL,
  libx11,
  ninja,
  python3,
}:
stdenv.mkDerivation {
  inherit (sources.aida-x) pname version src;

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libGL
    libx11
  ];

  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  postPatch = ''
    patchShebangs modules/dpf/utils/res2c.py
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3,lib/vst}
    cp bin/AIDA-X $out/bin
    cp bin/AIDA-X.clap $out/lib/clap
    cp -r bin/AIDA-X.lv2 $out/lib/lv2
    cp -r bin/AIDA-X.vst3 $out/lib/vst3
    cp bin/AIDA-X-vst2.so $out/lib/vst/AIDA-X.so

    runHook postInstall
  '';

  meta = {
    description = "An Amp Model Player leveraging AI";
    homepage = "https://aida-x.cc/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "AIDA-X";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
