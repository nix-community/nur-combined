{pkgs, ...}:
let
  setupScript = pkgs.writeText "setup" ''
    import math
  '';
in pkgs.writeShellScriptBin "c4me" ''
export TMPFILE=$(mktemp)
cat ${setupScript} >> $TMPFILE
read -e -t 0.1 && echo $REPLY >> $TMPFILE
echo "print($@)" >> $TMPFILE
${pkgs.python3}/bin/python $TMPFILE
rm $TMPFILE
''
