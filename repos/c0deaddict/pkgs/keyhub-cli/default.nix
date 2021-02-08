{ lib, stdenv, fetchurl, unzip, runtimeShell, openjdk, writeScriptBin, python3
, autoPatchelfHook, zlib }:

let

  wrapper = writeScriptBin "keyhub.py" ''
    #!${python3}/bin/python3 -u
    ${builtins.readFile ./keyhub.py}
  '';

in stdenv.mkDerivation rec {
  name = "keyhub-cli-${version}";
  version = "17.0";

  src = fetchurl {
    url = "https://files.topicus-keyhub.com/manual/keyhub-cli-${version}.zip";
    sha256 = "0n07yb7psjlwckpam44fxvmwj5fdnnp49dahzfkzf3d5p5hj062p";
  };

  buildInputs = [ autoPatchelfHook stdenv.glibc stdenv.cc.cc zlib ];
  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src
  '';

  # TODO: Keyhub ships with a self-contained binary, that is much faster than
  # the JVM version. It gives this error on `keyhub list`:
  #
  # InvalidAlgorithmParameterException:the trustAnchors parameter must be non-empty
  #
  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp linux/keyhub $out/bin
  # '';

  installPhase = ''
    mkdir -p "$out"/{bin,lib/java/keyhub}
    jar="$out/lib/java/keyhub/keyhub-cli.jar"
    cp keyhub-cli.jar "$jar"
    echo "#!${runtimeShell}" > "$out/bin/keyhub"
    echo "'${openjdk}/bin/java' -jar '$jar' \"\$@\"" >> "$out/bin/keyhub"
    chmod a+x "$out/bin/keyhub"
    ln -sf ${wrapper}/bin/keyhub.py $out/bin/keyhub.py
  '';

  meta = with lib; {
    homepage = "https://topicus-keyhub.com/";
    description = "A command line interface to Topicus KeyHub";
    maintainers = with maintainers; [ c0deaddict ];
  };
}
