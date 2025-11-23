{
  pkgs,
  lib ? pkgs.lib,
  fs ? lib.fileset,
}:

{
  mkHledgerFromCSV =
    {
      root,
      hledger ? pkgs.hledger,
    }:
    pkgs.stdenv.mkDerivation {
      name = "journal";
      nativeBuildInputs = [ hledger ];

      src = fs.toSource {
        root = root;
        fileset = fs.fileFilter (file: file.hasExt "csv" || file.hasExt "CSV" || file.hasExt "rules") root;
      };

      env.LANG = "en_US.UTF-8";
      env.LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      buildPhase = ''
        hledger \
          $(printf -- "--file %s " **/*.csv **/*.CSV) \
          $(printf -- "--rules %s " *.rules) \
          print > $out
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    };
}
