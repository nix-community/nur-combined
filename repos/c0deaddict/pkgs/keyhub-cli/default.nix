{ lib
, stdenv
, fetchurl
, unzip
, writeScriptBin
, python3
, autoPatchelfHook
, zlib
, glibc
}:

let

  wrapper = writeScriptBin "keyhub.py" ''
    #!${python3}/bin/python3 -u
    ${builtins.readFile ./keyhub.py}
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "keyhub-cli";
  version = "50";

  src = fetchurl {
    url = "https://files.topicus-keyhub.com/manual/keyhub-cli-${finalAttrs.version}.zip";
    hash = "sha256-s55aIX2LM3nb6ifUO0MNYnCZXe6kX0OhLuP6sj9jQNY=";
  };

  buildInputs = [ zlib ];
  nativeBuildInputs = [ unzip autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 linux/keyhub $out/bin/keyhub
    ln -sf ${wrapper}/bin/keyhub.py $out/bin/keyhub.py
  '';

  meta = with lib; {
    description = "A command line interface to Topicus KeyHub";
    homepage = "https://topicus-keyhub.com/";
    license = lib.licenses.unfree;
    mainProgram = "keyhub";
    maintainers = with maintainers; [ c0deaddict ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
