{ stdenv, fetchurl, dovecot, mylibs, fetchpatch }:

stdenv.mkDerivation (mylibs.fetchedGithub ./dovecot-deleted_to_trash.json // rec {
  buildInputs = [ dovecot ];
  patches = [
    (fetchpatch {
      name = "fix-dovecot-2.3.diff";
      url = "https://github.com/lexbrugman/dovecot_deleted_to_trash/commit/c52a3799a96104a603ade33404ef6aa1db647b2f.diff";
      sha256 = "0pld3rdcjp9df2qxbp807k6v4f48lyk0xy5q508ypa57d559y6dq";
    })
    ./fix_mbox.patch
  ];
  preConfigure = ''
    substituteInPlace Makefile --replace \
      "/usr/include/dovecot" \
      "${dovecot}/include/dovecot"
    substituteInPlace Makefile --replace \
      "/usr/lib/dovecot/modules" \
      "$out/lib/dovecot"
    '';
})
