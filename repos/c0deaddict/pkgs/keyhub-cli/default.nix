{ stdenv, fetchurl, unzip, runtimeShell, openjdk, writeScriptBin, python3 }:

let

  wrapper = writeScriptBin "keyhub.py" ''
    #!${python3}/bin/python3 -u
    ${builtins.readFile ./keyhub.py}
  '';

in

stdenv.mkDerivation rec {
  name = "keyhub-cli-${version}";
  version = "15.0";

  src = fetchurl {
    url = "https://files.topicus-keyhub.com/manual/keyhub-cli-${version}.zip";
    sha256 = "1x88n8ryxdyisikybplninyrbcgyq3653gyf79xxj1l11w8nsyj8";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p "$out"/{bin,lib/java/keyhub}
    jar="$out/lib/java/keyhub/keyhub-cli.jar"
    cp keyhub-cli.jar "$jar"
    echo "#!${runtimeShell}" > "$out/bin/keyhub"
    echo "'${openjdk}/bin/java' -jar '$jar' \"\$@\"" >> "$out/bin/keyhub"
    chmod a+x "$out/bin/keyhub"
    ln -sf ${wrapper}/bin/keyhub.py $out/bin/keyhub.py
  '';

  meta = with stdenv.lib; {
    homepage = "https://topicus-keyhub.com/";
    description = "A command line interface to Topicus KeyHub";
    maintainers = with maintainers; [ c0deaddict ];
  };
}
