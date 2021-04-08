{ stdenv, lib, config, fetchFromGitHub, pkgs, fetchpatch, ... }:

stdenv.mkDerivation rec {
  pname = "cpufetch";
  version = "0.94";

  src = fetchFromGitHub {
    owner = "Dr-Noob";
    repo = pname;
    rev = "v${version}";
    sha256 = "1gncgkhqd8bnz254qa30yyl10qm28dwx6aif0dwrj38z5ql40ck9";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/Dr-Noob/cpufetch/commit/812ee0acc6de439e3c4adfc3412e5edd05ef2335.patch";
      sha256 = "0az3rd88z8g3sdgx4rm6i0lbi454ij1kbwdp0hfswskh93iay7wb";
    })
  ];

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "Simple yet fancy CPU architecture fetching tool";
    homepage = "https://github.com/Dr-Noob/cpufetch";

    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
