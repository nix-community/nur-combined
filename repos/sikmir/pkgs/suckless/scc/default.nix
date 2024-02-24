{ lib, stdenv, fetchgit, qbe }:

stdenv.mkDerivation {
  pname = "scc";
  version = "2023-10-20";

  src = fetchgit {
    url = "git://git.simple-cc.org/scc";
    rev = "1f350b8f200581b66c4a5fc2dd74ee2fbf574c4a";
    sha256 = "sha256-2tR2ETiMFZABY3GPr8ovHRZ2d48Hrck0vK8RqID65Us=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/cmd/Makefile \
      --replace-fail "git submodule" "#git submodule"
  '';

  #buildInputs = [ qbe ];

  makeFlags = [ "PREFIX=$(out)" "AR:=$(AR)" "AS:=$(AS)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" "HOSTCC=${stdenv.cc.targetPrefix}cc" ];

  #doCheck = true;
  checkTarget = "tests";

  meta = with lib; {
    description = "Simple c99 compiler";
    homepage = "https://www.simple-cc.org/";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
