{
  lib,
  stdenv,
  fetchurl,
  unzip,
  wine,
  makeWrapper,
  withExLexer ? true,
}:
let
  exlexer = fetchurl {
    url = "mirror://sourceforge/synwrite-addons/PyPlugins/plugin.Alexey.ExLexer.zip";
    hash = "sha256-O9wOglJp4XExWV8ODoVra3VyaqRmhB51/tupRmqDdqY=";
  };
in
stdenv.mkDerivation rec {
  pname = "synwrite";
  version = "6.41.2780";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/synwrite/Release/SynWrite.${version}.zip"
      "http://uvviewsoft.com/synwrite/files/SynWrite.${version}.zip"
    ];
    hash = "sha256-/WleyQoo98RLX1MJGVjjlPmZJHxiCV4ulrb1eqNHOZ8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase =
    ''
      mkdir -p $out/opt/synwrite
      cp -r . $out/opt/synwrite

      makeWrapper ${wine}/bin/wine $out/bin/synwrite \
        --run "[ -d \$HOME/.synwrite ] || { cp -r $out/opt/synwrite \$HOME/.synwrite && chmod -R +w \$HOME/.synwrite; }" \
        --add-flags "\$HOME/.synwrite/Syn.exe"
    ''
    + lib.optionalString withExLexer ''
      unzip ${exlexer} -d $out/opt/synwrite/Py/syn_exlexer
    '';

  preferLocalBuild = true;

  meta = {
    description = "Advanced text editor for programmers and Notepad replacement";
    homepage = "https://cudatext.github.io/synwrite/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mpl11;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
