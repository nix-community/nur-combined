{pkgs, ...}:
pkgs.writeShellScriptBin "c4me" ''
TMPFILE=$(mktemp)
[[ ! "$DEBUG" == "" ]] && echo "[i] TMPFILE: $TMPFILE"
cp ${./template.py} $TMPFILE
read -e -t 0.1 && echo $REPLY >> $TMPFILE
echo "main()" >> $TMPFILE
${pkgs.python3}/bin/python $TMPFILE "$@"
[[ "$DEBUG" == "" ]] && rm $TMPFILE
''
