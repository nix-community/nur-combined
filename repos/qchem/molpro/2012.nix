{ stdenv, requireFile, python, token } :

let
  version = "2012.1.12";

in stdenv.mkDerivation {
  pname = "molpro";
  inherit version;

  src = requireFile {
    url = http://www.molpro.net;
    name = "molpro-mpp-${version}.Linux_x86_64.sh.gz";
    sha256 = "014j260dcpn8bgyl6gs9n5px4p3kimy6x6d2yh3w2hj1bm06n3ai";
  };

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

  # Install test requires ssh now!?
  # refuses to validate license with localhost only
  doInstallCheck = false;

  installCheckPhase = ''
     #
     # Minimal check if installation runs properly
     #

     export HOST=localhost

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

  meta = with stdenv.lib; {
    description = "Quantum chemistry program package";
    homepage = https://www.molpro.net;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

