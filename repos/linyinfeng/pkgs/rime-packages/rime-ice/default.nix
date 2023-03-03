{ sources, stdenv, lib, librime }:

stdenv.mkDerivation {
  inherit (sources.rime-ice) pname version src;

  nativeBuildInputs = [
    # TODO use librime to precompile schemas
    # librime # for rime_deployer
  ];

  buildPhase = ''
    # for s in $(ls *.schema.yaml); do
    #   rime_deployer --compile $s;
    # done
  '';

  installPhase = ''
    # rm build/*.txt
    # find . -type l -delete

    install -Dm644 cn_dicts/* -t "$out/share/rime-data/cn_dicts"
    install -Dm644 en_dicts/* -t "$out/share/rime-data/en_dicts"
    install -Dm644 opencc/*   -t "$out/share/rime-data/opencc"
    # install -Dm644 build/*    -t "$out/share/rime-data/build/"

    install -Dm644 *.{schema,dict}.yaml  -t "$out/share/rime-data/"
    install -Dm644 *.{lua,gram}          -t "$out/share/rime-data/"
    install -Dm644 symbols_custom.yaml   -t "$out/share/rime-data/"
  '';

  meta = with lib; {
    homepage = "https://github.com/iDvel/rime-ice";
    description = "A long-term maintained simplified Chinese RIME schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
