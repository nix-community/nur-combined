{ stdenv, buildFHSUserEnv, fetchFromGitHub,
  cmake,
  readline6,
}:

stdenv.mkDerivation rec {
  pname = "dptf";
  version = "8.7.10100";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "dptf";
    rev = version;
    sha256 = "1s143837vym0q3rajw62s7xjv82b2j5kqr5pj6brhr31s7c5nzz8";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ readline6 ];

  enableParallelBuilding = true;

  dontConfigure = true;

  patches = [
    ./build-fixes.patch
  ];

  postPatch = /* sh */ ''
    substituteInPlace ESIF/Products/ESIF_UF/Sources/lin/main.c \
      --replace =/usr/share/dptf/log =/var/log/dptf \
      --replace =/etc/ =$out/etc/ \
      --replace =/usr/ =$out/usr/
  '';

  buildPhase = /* sh */ ''
    cmake -S DPTF/Linux -B DPTF/Linux/build
    make -j$NIX_BUILD_CORES -C DPTF/Linux/build
    make -j$NIX_BUILD_CORES -C ESIF/Products/ESIF_UF/Linux
    make -j$NIX_BUILD_CORES -C ESIF/Products/ESIF_CMP/Linux
    make -j$NIX_BUILD_CORES -C ESIF/Products/ESIF_WS/Linux
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/{bin,etc/dptf,usr/share/dptf/ufx64}

    cp DPTF/Linux/build/x64/release/Dptf*.so $out/usr/share/dptf/ufx64
    cp ESIF/Products/ESIF_CMP/Linux/esif_cmp.so $out/usr/share/dptf/ufx64
    cp ESIF/Products/ESIF_WS/Linux/esif_ws.so $out/usr/share/dptf/ufx64

    cp ESIF/Packages/DSP/dsp.dv $out/etc/dptf
    cp ESIF/Products/ESIF_UF/Linux/esif_ufd $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/dptf/;
    description = "Intel Dynamic Platform and Tuning Framework";
    platforms = platforms.linux;
    license = with licenses; [ apsl20 [ bsd3 gpl2 ] ];
    maintainers = with maintainers; [ rummik ];
  };
}
