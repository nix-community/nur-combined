{ lib, stdenv, requireFile, fetchurl, patchelf, python, token
} :

let
  version = "2018.2.0";

in stdenv.mkDerivation {
  pname = "molpro";
  inherit version;

  src = requireFile {
    url = http://www.molpro.net;
    name = "molpro-mpp-${version}.linux_x86_64_openmp.sh.gz";
    sha256 = "1fqia59y26sniiygm2qbwasyxvc5jvnm2kfjvpycpkvfnh604d6r";
  };

  nativeBuildInputs = [ patchelf ];
  buildInputs = [ python ];

  unpackPhase = ''
    mkdir -p source
    gzip -d -c $src > source/install.sh
    cd source
  '';

  postPatch = ''
    sed -i "1,/_EOF_/s:/bin/pwd:pwd:" install.sh
  '';

  configurePhase = ''
    export MOLPRO_KEY="${token}"
  '';

  installPhase = ''
    sh install.sh -batch -prefix $out
  '';

  dontStrip = true;

  doInstallCheck = false;

  installCheckPhase = ''
     #
     # Minimal check if installation runs properly
     #

     export MOLCAS_WORKDIR=./
     inp=water

     cat << EOF > $inp.inp
     basis=STO-3G
     geom = {
     3
     Angstrom
     O       0.000000  0.000000  0.000000
     H       0.758602  0.000000  0.504284
     H       0.758602  0.000000 -0.504284
     }
     HF
     EOF

     # pretend this is a writable home dir
     export HOME=$PWD

     $out/bin/molpro $inp.inp

     echo "Check for sucessful run:"
     grep "RHF STATE  1.1 Energy" $inp.out
     echo "Check for correct energy:"
     grep "RHF STATE  1.1 Energy" $inp.out | grep 74.880174
  '';

  meta = with lib; {
    description = "Quantum chemistry program package";
    homepage = https://www.molpro.net;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

