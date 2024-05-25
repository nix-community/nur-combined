{
  lib,
  stdenv,
  fetchgit,
  qbe,
}:

stdenv.mkDerivation {
  pname = "scc";
  version = "0-unstable-2024-02-11";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "527601ad4c29e586f0ce307353583c5c09f3c321";
    sha256 = "sha256-tog3LCUQwjNb8ZIoztmnKNL8mo/9ik9NXNJLQmAPltA=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/cmd/Makefile \
      --replace-fail "git submodule" "#git submodule"
  '';

  #buildInputs = [ qbe ];

  makeFlags = [
    "PREFIX=$(out)"
    "AR:=$(AR)"
    "AS:=$(AS)"
    "CC:=$(CC)"
    "RANLIB:=$(RANLIB)"
    "HOSTCC=${stdenv.cc.targetPrefix}cc"
  ];

  #doCheck = true;
  checkTarget = "tests";

  meta = {
    description = "Simple c99 compiler";
    homepage = "https://www.simple-cc.org/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
