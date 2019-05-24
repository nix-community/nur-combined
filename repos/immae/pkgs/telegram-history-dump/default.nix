{ stdenv, ruby, mylibs }:
stdenv.mkDerivation (mylibs.fetchedGithub ./telegram-history-dump.json // {
  installPhase = ''
    mkdir -p $out/lib $out/bin
    cp -a $src $out/lib/telegram-history-dump
    ln -s $out/lib/telegram-history-dump/telegram-history-dump.rb $out/bin/telegram-history-dump
    '';
  buildInputs = [ ruby ];
})
