{ lib, stdenv, requireFile, gfortran, openblas } :

let
  # I am guessing here, that's the timestamp of the README
  version = "20140610";

in stdenv.mkDerivation {
  pname = "mesa";
  inherit version;

  src = requireFile {
    name = "mesa_lucchese.tar.xz";
    sha256 = "0xp287r53xfvgcfv1c2kpl68wsvmfkh1vb0f3l941jb0ry4wh5w0";
    message = "The tarball for mesa needs to be in nix store";
  };

  nativeBuildInputs = [ gfortran ];
  buildInputs = [ openblas ];

  # prepare for building the ILP64 version
  postPatch = ''
    sed -i 's/BLASUSE=.*/BLASUSE=-lopenblas/' include/appleAbsoft11.gfi8.sh
    patchShebangs ./
  '';

  buildPhase = ''
    ./Makemesa.sh all appleAbsoft11.gfi8
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/mesa

    cp binappleAbsoft11.gfi8/* $out/bin
    cp mesa.dat $out/share/mesa

    # wrapper to start mesa
    cat << EOF > $out/bin/mesa
    #!/bin/bash
    $out/bin/mesa_get_data
    mkdir -p tmp
    $out/bin/optmesa \$@
    EOF

    cat << EOF > $out/bin/mesa_get_data
    #!/bin/bash
    if [ ! -f mesa.dat ]; then
      cp $out/share/mesa/mesa.dat .
    fi
    EOF

    chmod +x $out/bin/mesa $out/bin/mesa_get_data
  '';

  doInstallCheck = true;

  mesaInp = ./mesa.inp;

  installCheckPhase = ''
    mkdir test; cd test
    cp $mesaInp mesa.inp

    export  PATH=$PATH:$out/bin
    mesa

    echo "SCF Energy:"
    grep "9        -1.1231191" mesa.out

    echo "Check for job completion"
    grep summary: mesa.out
  '';

  meta = with lib; {
    description = "Electronic structure and scattering program";
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

