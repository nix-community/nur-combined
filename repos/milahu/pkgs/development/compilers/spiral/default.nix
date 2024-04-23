{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
#, withCuda ? false # TODO
}:

stdenv.mkDerivation rec {
  pname = "spiral";
  version = "8.5.1";

  # https://github.com/spiral-software/spiral-software
  src = fetchFromGitHub {
    owner = "spiral-software";
    repo = "spiral-software";
    rev = version;
    hash = "sha256-Gnt122wlj7r0lrUJcrRoUh7ETddsWXdnA969YRFz3fo=";
  };

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    #cuda # TODO nvcc
  ];

  # TODO? fix install paths in CMakeLists.txt
  /*
    -- Install configuration: "Release"
    -- Installing: /build/source/bin/spiral
    -- Installing: /build/source/bin/spirald
    -- Installing: /build/source/bin/_spiral.g
    -- Installing: /build/source/gap/bin/gap
    -- Installing: /build/source/gap/bin/checkforGpu
    -- Installing: /build/source/gap/bin/exectest.py
    -- Installing: /build/source/gap/bin/catfiles.py
  */

  /*
  postInstall = ''
    cd ..
    rm gap/bin/gap.bat
    chmod +x gap/bin/gap.sh
    mkdir -p $out/opt/spiral
    cp -r -t $out/opt/spiral bin namespaces
    mkdir -p $out/opt/spiral/gap
    cp -r -t $out/opt/spiral/gap gap/bin gap/lib gap/grp
    mkdir -p $out/bin
    cat >$out/bin/spiral <<EOF
    #!/bin/sh
    exec $out/opt/spiral/bin/spiral "\$@"
    EOF
    chmod +x $out/bin/spiral
    # todo more?
    cp -r . $out/build
  '';
  */

  # TODO reduce file count
  postInstall = ''
    cd ..
    rm -rf build
    rm gap/bin/gap.bat
    chmod +x gap/bin/gap.sh
    mkdir -p $out/opt
    cp -r . $out/opt/spiral
    mkdir -p $out/bin
    cat >$out/bin/spiral <<EOF
    #!/bin/sh
    exec $out/opt/spiral/bin/spiral "\$@"
    EOF
    chmod +x $out/bin/spiral
  '';

  meta = with lib; {
    description = "generate platform-tuned implementations of digital signal processing (DSP) algorithms and other numerical kernels";
    longDescription = ''
      push the limits of automation in software and hardware development and optimization
      for digital signal processing (DSP) algorithms and other numerical kernels
      beyond what is possible with current tools.
    '';
    homepage = "https://spiral.net/";
    license = licenses.bsd2WithViews;
    maintainers = with maintainers; [ ];
    mainProgram = "spiral";
    platforms = platforms.all;
  };
}
