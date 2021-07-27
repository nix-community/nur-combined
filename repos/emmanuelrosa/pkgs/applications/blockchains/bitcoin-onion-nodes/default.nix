{ stdenv, lib, fetchFromGitHub, gawk, gnused, writeText
, ignoreNodes ? lib.lists.singleton "IGNORE_ME"
}:

let
  description = "A list of over 600 Bitcoin Core nodes running as Tor v3 onion services.";
in stdenv.mkDerivation rec {
  name = "bitcoin-onion-nodes-${version}.txt";
  version = "f79ad4c1d7f2c46420c6042d52da52d18a9d4345";

  src = fetchFromGitHub {
    owner = "emmanuelrosa";
    repo = "bitcoin-onion-nodes";
    rev = version;
    sha256 = "057y4vk6jkcp0xbxsx1fgp0dddisz1isw2n0pw4sj30jk8yfii12";
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
