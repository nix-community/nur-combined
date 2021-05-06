{ stdenv, lib, fetchFromGitHub, gawk, gnused, writeText
, ignoreNodes ? lib.lists.singleton "IGNORE_ME"
}:

let
  description = "A list of over 500 Bitcoin Core nodes running as Tor onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "45ce89b8148d3b8862d29a17058eb5bc6e2dbb74";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "0imgrh4d8s367c7qwzsi1davp4kz46sg947as5h4cl2frdadrpy7";
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
