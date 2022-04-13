{stdenv, lib, melissa, cmake, gfortran, openmpi, python3 }:

stdenv.mkDerivation rec {
    pname = "heat-pde";
    version = melissa.version;

    src = "${melissa}/share/melissa/examples/heat-pde";

    buildInputs = [ melissa cmake gfortran openmpi python3 ];

    postInstall = ''
        mkdir -p $out
        cp -r ${src}/*.py $out
        chmod +x $out/*.py
    '';

    meta = with lib; {
      homepage = "https://melissa-sa.github.io/";
      description = "Melissa framework example - heat equation";
      platforms = platforms.linux;
      broken = false;
    };
}
