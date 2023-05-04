{ lib, gawk, stdenvNoCC, unified-hosts-lists }:
stdenvNoCC.mkDerivation {
  name = "unbound-zones-adblock";
  version = unified-hosts-lists.version;

  src = unified-hosts-lists;

  dontUnpack = true;

  installPhase =
    let
      gawkCmd = lib.concatStringsSep " " [
        ''${gawk}/bin/awk''
        '''{sub(/\r$/,"")}''
        ''{sub(/^127\.0\.0\.1/,"0.0.0.0")}''
        ''BEGIN { OFS = "" }''
        ''NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' ''
      ];
    in
    ''
      mkdir -p $out
      for file in $src/*; do
          ${gawkCmd} $file | tr '[:upper:]' '[:lower:]' | sort -u > $out/$(basename $file)
      done
    '';

  meta = with lib; {
    description = "Unified host lists, ready to be used by unbound";
    longDescription = ''
      This is a simple derivation based on StevenBlack's unified hosts list.
      The files have been modified for easy use wih unbound.
    '';
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ambroisie ];
  };
}
