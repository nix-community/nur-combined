{ lib, gawk, stdenvNoCC, stevenblack-blocklist }:
stdenvNoCC.mkDerivation {
  name = "unbound-zones-adblock";
  inherit (stevenblack-blocklist) version;

  src = stevenblack-blocklist;

  dontUnpack = true;

  installPhase =
    let
      gawkCmd = lib.concatStringsSep " " [
        (lib.getExe gawk)
        '''{sub(/\r$/,"")}''
        ''{sub(/^127\.0\.0\.1/,"0.0.0.0")}''
        ''BEGIN { OFS = "" }''
        ''NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' ''
      ];
    in
    ''
      shopt -s globstar
      for file in $src/**/hosts; do
          outFile="$out/''${file#$src}"
          mkdir -p "$(dirname "$outFile")"
          ${gawkCmd} $file | tr '[:upper:]' '[:lower:]' | sort -u > "$outFile"
      done
    '';

  meta = with lib; {
    description = "Unified host lists, ready to be used by unbound";
    longDescription = ''
      This is a simple derivation based on StevenBlack's unified hosts list.
      The files have been modified for easy use with unbound.
    '';
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.all;
  };
}
