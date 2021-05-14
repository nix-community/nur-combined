{ lib, stdenv, fetchurl, unzip, wine, makeWrapper, withExLexer ? true }:
let
  plugins = fetchurl {
    url = "http://uvviewsoft.com/synwrite/files/SynWrite_saved_plugins.zip";
    hash = "sha256-bWc3/fvc++nSVExC1iO1g+DjlXEal5CZQkc4gZB0xU0=";
  };
in
stdenv.mkDerivation rec {
  pname = "synwrite-bin";
  version = "6.41.2780";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/synwrite/Release/SynWrite.${version}.zip"
      "http://uvviewsoft.com/synwrite/files/SynWrite.${version}.zip"
    ];
    hash = "sha256-/WleyQoo98RLX1MJGVjjlPmZJHxiCV4ulrb1eqNHOZ8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/synwrite
    cp -r . $out/opt/synwrite

    makeWrapper ${wine}/bin/wine $out/bin/synwrite \
      --run "[ -d \$HOME/.synwrite ] || { cp -r $out/opt/synwrite \$HOME/.synwrite && chmod -R +w \$HOME/.synwrite; }" \
      --add-flags "\$HOME/.synwrite/Syn.exe"
  '' + lib.optionalString withExLexer ''
    unzip -j ${plugins} SynWrite_saved_plugins/PyPlugins/plugin.Alexey.ExLexer.zip
    unzip plugin.Alexey.ExLexer.zip -d $out/opt/synwrite/Py/syn_exlexer
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "Advanced text editor for programmers and Notepad replacement";
    homepage = "http://uvviewsoft.com/synwrite/";
    license = licenses.mpl11;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
