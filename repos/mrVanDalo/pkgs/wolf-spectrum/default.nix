{ stdenv, fetchFromGitHub, libjack2, lv2, xorg, liblo, libGL, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "wolf-spectrum";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "pdesaulniers";
    repo = "wolf-spectrum";
    rev = "v${version}";
    sha256 = "17db1jlj7vb1xyvkdhhrsvdbwb7jqw6i4168cdvlj3yvn2ra8gpm";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libjack2 lv2 xorg.libX11 liblo libGL xorg.libXcursor ];

  makeFlags =
    [ "BUILD_LV2=true" "BUILD_DSSI=false" "BUILD_VST2=true" "BUILD_JACK=true" ];

  patchPhase = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  installPhase = ''
    mkdir -p $out/lib/lv2
    #mkdir -p $out/lib/dssi
    mkdir -p $out/lib/vst
    mkdir -p $out/bin/
    cp -r bin/wolf-spectrum.lv2    $out/lib/lv2/
    #cp -r bin/wolf-spectrum-dssi*  $out/lib/dssi/
    cp -r bin/wolf-spectrum-vst.so $out/lib/vst/
    cp -r bin/wolf-spectrum        $out/bin/
  '';

  meta = with stdenv.lib; {
    homepage = "https://pdesaulniers.github.io/wolf-shaper/";
    description = "Waveshaper plugin with spline-based graph editor";
    license = licenses.gpl3;
    maintainers = [ maintainers.magnetophon ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
