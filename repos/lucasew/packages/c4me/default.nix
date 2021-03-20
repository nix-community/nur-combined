{pkgs, ...}:
let
  input = builtins.readFile ./template.py;
in pkgs.writeShellScriptBin "c4me" ''
TMPFILE=$(mktemp)
[[ ! "$DEBUG" == "" ]] && echo "[i] TMPFILE: $TMPFILE"
echo '${input}' >> $TMPFILE
read -e -t 0.1 && echo $REPLY >> $TMPFILE
echo "main()" >> $TMPFILE
${pkgs.python3}/bin/python $TMPFILE "$@"
[[ "$DEBUG" == "" ]] && rm $TMPFILE
''
