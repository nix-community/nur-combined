{ lib, fetchFromGitHub, sbtix, stoke, python }:

let
  githash = "e5b5ebe681920036987aec04f1b625532fa6b962";
in
sbtix.buildSbtProgram rec {
  name = "strata-${stoke.stokePlatform}-${version}";
  version = "2016-04-11";
  src = fetchFromGitHub {
    owner = "StanfordPL";
    repo = "strata";
    rev = githash;
    sha256 = "17dbm3il3f9qdmixw3mi6hmkiacxmyb6mm2vj20ikgiarx8rgr3y";
  };
  repo = [
    (import ./manual-repo.nix)
    (import ./repo.nix)
    (import ./project/repo.nix)
    # (import ./project/project/repo.nix)
  ];

  buildInputs = [ python ];

  patches = [
    ./sbt-native-packager.patch
    ./subst.patch
  ];

  postPatch = ''
    githash=${githash}
    substituteInPlace src/main/scala/strata/util/IO.scala --subst-var out --subst-var githash
  '';

  preFixup = ''
    mv resources scripts $out/
    ln -s ${stoke} $out/stoke

    sed -i $out/bin/strata -e '2iunset LD_LIBRARY_PATH'
  '';

  meta = with lib; {
    description = "Automatic inference of a formal specification of the x86_64 instruction set";
    license = licenses.unfree; # XXX ?
    maintainers = with maintainers; [ dtzWill ];
  };
}
