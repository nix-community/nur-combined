{ stdenv, fetchgit, dtc }:

stdenv.mkDerivation rec {
  pname = "kvmtool";
  version = "2020-08-21";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/will/${pname}.git";
    rev = "90b2d3adadf218dfc6bdfdfcefe269843360223c";
    sha256 = "sha256-ojuw9fjzQTHmI4fjoVIRAifw6k4FIHLIcKBq4Pi0Awg=";
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];

  buildInputs = [ dtc ];

  meta = with stdenv.lib; {
    description = "A lightweight tool for hosting KVM guests";
    homepage =
      "https://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git/tree/README";
    license = licenses.gpl2;
  };
}
