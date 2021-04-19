{ stdenv, lib, fetchFromGitHub, gawk, gnused, writeText
, ignoreNodes ? lib.lists.singleton "IGNORE_ME"
}:

let
  description = "A list of over 500 Bitcoin Core nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "62f53fb5d223e86deee21cd3fe8c8390d195fd45";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "1vpnrimppip6h13q5xm5idcnn12pya738xmcqs3ih0xjqrx43ns4";
  };

  ignoreFile = writeText "ignore.txt" ''
    ${lib.strings.concatStringsSep "\n" ignoreNodes}
  '';

  buildPhase = ''
    cp nodes.txt input.txt

    cat ${ignoreFile} | while read line; do
      prefix=$(echo $line | head -c 8)
      ${gnused}/bin/sed "/^$prefix/d" input.txt > nodes-filtered.txt
      cp nodes-filtered.txt input.txt
    done

    cat nodes-filtered.txt | sort | uniq > nodes-final.txt
  '';

  installPhase = ''
    ${gawk}/bin/awk -f mknodes.awk <nodes-final.txt >$out
  '';

  meta = with lib; {
    inherit description;
    homepage = https://github.com/emmanuelrosa/bitcoin-onion-nodes;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
