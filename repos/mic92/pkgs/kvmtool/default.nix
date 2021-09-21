{ stdenv, fetchgit, lib, zlib, libaio }:
stdenv.mkDerivation {
  pname = "kvmtool";
  version = "2021-07-16";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git";
    rev = "415f92c33a227c02f6719d4594af6fad10f07abf";
    sha256 = "sha256-OBpYgzB0QBVMwQ0wh6p586XFj2U8beR23LkrZ57N0PU=";
  };

  buildInputs = [
    zlib libaio
    # FIXME: not detecting: libbfd
  ];
  makeFlags = [ "prefix=${placeholder "out"}" ];

  meta = with lib; {
    description = "A lightweight tool for hosting KVM guests";
    homepage =
      "https://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git/tree/README";
    license = licenses.gpl2;
  };
}
