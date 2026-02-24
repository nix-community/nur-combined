{
  pkgs,
  lib ? pkgs.lib,
}:

{
  mkHledgerFromCSV =
    { root }:
    pkgs.stdenv.mkDerivation {
      name = "journal";

      src = lib.sourceFilesBySuffices root [
        "csv"
        "CSV"
        "rules"
        # "journal"
      ];

      nativeBuildInputs = [ pkgs.hledger ];

      env = {
        LANG = "en_US.UTF-8";
        LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      };

      buildPhase = ''
        runHook preBuild

        hledger \
          $(printf -- "--file %s " **/*.csv **/*.CSV) \
          $(printf -- "--rules %s " *.rules) \
          print > $out

        runHook postBuild
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    };
}
