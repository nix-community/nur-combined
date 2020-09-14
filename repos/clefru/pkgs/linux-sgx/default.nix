{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "linux-sgx";

  src = (fetchFromGitHub {
    owner = "intel";
    rev = "bf22963411f8cd1e8d01989eb9979e0b114871ff";
    sha256 = "1apj5vxjnlaz8z863n33ha26xbq9czv04rqcvj231wjn0v7gq3ap";
    repo = "linux-sgx";
    # linux-sgx downloads some prebuilt binaries. Do that after
    # fetching from github. wget is required for that.
    extraPostFetch = "cd $out; bash ./download_prebuilt.sh";
  }).overrideAttrs (attrs: { buildInputs = attr.buildInputs ++ [ wget cacert ]; });

  phases = "unpackPhase patchPhase buildPhase installPhase";

  buildInputs = [ gcc bash automake autoconf pkgconfig libtool ocaml
    ocamlPackages.ocamlbuild libressl wget python protobuf protobufc
    curl coreutils file which mktemp ];

  patches = [ ./nix-compat.diff ];
  buildFlags = "sdk_install_pkg psw_install_pkg";
#  buildPhase = ''
#    make sdk_install_pkg psw_install_pkg
# ''
  preBuild = ''
    patchShebangs .
  '';

  installPhase = ''
   linux/installer/bin/sgx_linux_x64_sdk_* -prefix $out;

   cd linux/installer/common/psw/output
   PSW_INST_DIR=$(mktemp -d /tmp/psw-install.XXXXX)
   make install DESTDIR=$PSW_INST_DIR
   mv $PSW_INST_DIR/opt/intel/sgxpsw $out/sgxpsw
   mv $PSW_INST_DIR/usr/lib64 $out/lib
  '';

  meta = {
    description = "Intel SGX for Linux";
    homepage = https://01.org/intel-softwareguard-extensions;
    broken = true; # Fails because of some compiler warnings. Should be easy to fix.
  };
}
