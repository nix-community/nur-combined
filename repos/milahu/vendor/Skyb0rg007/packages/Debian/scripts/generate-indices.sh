#!/bin/sh

if [ $# -ne 1 ]; then
    echo >&2 "Usage: $0 <dir>"
    exit 1
fi
cd "$1" || exit 1

script="$(mktemp)"
cat > "$script" <<'EOF'
#!/bin/bash

dir="$1"

if [ -e "$dir/index.html" ]; then
  echo >&2 "Index exists ($dir/index.html), skipping"
  exit
fi

echo >&2 "Creating index for '$dir'"
exec 3>"$dir/index.html"

if [ "$dir" = "." ]; then
    name="/"
else
    name="${dir:1}"
fi

echo >&3 "<!DOCTYPE html>"
echo >&3 "<html>"
echo >&3 "  <head>"
echo >&3 "    <meta charset=\"utf-8\">"
echo >&3 "    <title>Index of $name</title>"
echo >&3 "  </head>"
echo >&3 "  <body>"
echo >&3 "    <h1>Index of $name</h1>"
echo >&3 "    <table>"
echo >&3 "      <thead>"
echo >&3 "        <tr>"
echo >&3 "          <th scope=\"col\">Name</th>"
echo >&3 "          <th scope=\"col\">Size</th>"
echo >&3 "        </tr>"
echo >&3 "        <tr>"
echo >&3 "          <th colspan=\"2\"><hr></th>"
echo >&3 "        </tr>"
echo >&3 "      </thead>"
echo >&3 "      <tbody>"
if [ "$dir" != "." ]; then
echo >&3 "        <tr>"
echo >&3 "          <td><a href=\"..\">Parent Directory</a></td>"
echo >&3 "          <td align=\"right\">-</td>"
echo >&3 "        </tr>"
fi
for f in "$dir"/*; do
  if [ -d "$f" ]; then
echo >&3 "        <tr>"
echo >&3 "          <td><a href=\"${f:1}\">$(basename "$f")/</a></td>"
echo >&3 "          <td align=\"right\">-</td>"
echo >&3 "        </tr>"
    
  elif [ -f "$f" ]; then
    if [ "$(basename "$f")" != "index.html" ]; then
echo >&3 "        <tr>"
echo >&3 "          <td><a href=\"${f:1}\">$(basename "$f")</a></td>"
echo >&3 "          <td align=\"right\">$(stat -c "%s" "$f" | numfmt --to=iec)B</td>"
echo >&3 "        </tr>"
    fi
  else
    echo >&2 "Ignoring '$f'"
  fi
done
echo >&3 "      </tbody>"
echo >&3 "    </table>"
echo >&3 "  </body>"
echo >&3 "</html>"

exec 3>&-
EOF
chmod +x "$script"
trap 'rm -f "$script"' EXIT

find . -type d -exec "$script" {} \;
