{ stdenv, mylibs, libetpan, openssl, autoconf, groff, slang, yacc }:
stdenv.mkDerivation (mylibs.fetchedGithub ./flrn.json // {
  buildInputs = [ libetpan openssl autoconf groff slang yacc ];
  preConfigure = ''
    sed -i -e "s/test -e configure/false/" configure.in
    autoconf
    sed -i -e '/define CHECK_MAIL/d' src/flrn_config.h
    sed -i -e '/DEFAULT_DIR_FILE/s@".flrn"@".config/flrn"@' src/flrn_config.h
    sed -i -e '/DEFAULT_CONFIG_FILE/s@".flrnrc"@"flrnrc"@' src/flrn_config.h
    sed -i -e '/DEFAULT_FLNEWS_FILE/s@".flnewsrc"@"flnewsrc"@' src/flrn_config.h
    sed -i -e '/flrn_char chaine/s@18@20@' src/flrn_command.c
    '';
})
