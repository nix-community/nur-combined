{ lib, stdenv, requireFile, fetchurl, patchelf, python
, token
, comm ? "sockets"
} :

assert token != null;
assert (comm == "sockets") || (comm == "mpipr");

let
  version = "2021.2.1";
  url = http://www.molpro.net;

in stdenv.mkDerivation {
  pname = "molpro";
  inherit version;

  src = requireFile (if comm == "sockets" then {
    inherit url;
    name = "molpro-mpp-${version}.linux_x86_64_sockets.sh.gz";
    sha256 = "05ngn0inffng12i3nn820f4cz9g28lz71mi8v5jzvwxbqim0dhds";
  } else {
    inherit url;
    name = "molpro-mpp-${version}.linux_x86_64_mpipr.sh.gz";
    sha256 = "1hragygrqr3zwimc7c1vv2nkpzgrnjx32xrlsn21r1xgxcp66zni";
  });

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

  postFixup = ''
    #
    # Since version 2019.1 the binaris are dyanmically linked
    for bin in hydra_pmi_proxy molpro.exe mpiexec.hydra; do
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/$bin
    done
  '';

  doInstallCheck = true;

  installCheckPhase = ''
     #
     # Minimal check if installation runs properly
     #
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
     # need to specify interface or: "MPID_nem_tcp_init(373) gethostbyname failed"
     $out/bin/molpro --launcher \
       "$out/bin/mpiexec.hydra -iface lo $out/bin/molpro.exe" $inp.inp

     echo "Check for sucessful run:"
     grep "RHF STATE 1.1 Energy" $inp.out
     echo "Check for correct energy:"
     grep "RHF STATE 1.1 Energy" $inp.out | grep 74.880174
  '';

  meta = with lib; {
    description = "Quantum chemistry program package";
    homepage = url;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

