{ fetchgit, stdenv, lib }:
stdenv.mkDerivation rec {
  name = "romcc-${version}";
  # last release to include romcc:
  # https://review.coreboot.org/plugins/gitiles/coreboot/+/refs/tags/4.11/util/romcc/
  version = "4.11";

  src = "${
      fetchgit {
        url = "https://review.coreboot.org/coreboot.git";
        rev = version;
        sha256 = "sha256-DJGBT7aefzqNA6d/fb0djlIOuXiS7qNLh1P8r1FWFvE=";
      }
    }/util/romcc";

  installPhase = ''
    runHook preInstall
    install -Dm755 build/romcc $out/bin/romcc
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "Compile a C source file generating a binary that does not implicitly use RAM";
    longDescription = ''
      A C compiler which produces binaries which do not rely on RAM, but instead
      only use CPU registers.

      It is prominently used in the coreboot project to compile C code which
      needs to run before the firmware has initialized the RAM, but can be
      used for other purposes, too.
    '';
    license = licenses.gpl2;
  };
}
