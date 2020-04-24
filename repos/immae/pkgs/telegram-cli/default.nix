{ stdenv, mylibs, pkgconfig, libevent, lua, jansson, openssl, readline, zlib, libconfig }:
stdenv.mkDerivation (mylibs.fetchedGithub ./telegram-cli.json // {
  buildInputs = [ pkgconfig libevent lua jansson openssl readline zlib libconfig ];
  preBuild = ''
    sed -i -e 's@"/etc/" PROG_NAME "/server.pub"@"'$out'/etc/server.pub"@' main.c
    '';
  installPhase = ''
    mkdir -p $out
    install -Dm755 bin/telegram-cli $out/bin/telegram-cli
    install -Dm644 tg-server.pub $out/etc/server.pub
    install -Dm644 debian/telegram-cli.8 $out/man/man8/telegram-cli.8
    '';
})
