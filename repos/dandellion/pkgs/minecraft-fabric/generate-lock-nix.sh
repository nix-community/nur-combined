curl https://meta.fabricmc.net/v2/versions/loader/1.18.1/0.12.12/server/json \
| jq -r '
  .mainClass,
  (.libraries[]
  | .url as $url
  | .name | split(":") as [$dir, $name, $version]
  |"\($name)-\($version).zip|\($url)\($dir|sub("\\.";"/";"g"))/\($name)/\($version)/\($name)-\($version).jar"
  )' \
| {
    echo '{'
    read mainClass;
    echo "  mainClass = \"$mainClass\";"
    echo "  libraries = ["
    while IFS="|" read name url; do
        hash=$(nix-prefetch-url $url);
        echo "    { name = \"$name\"; sha256 = \"$hash\"; url = \"$url\"; }"
    done
    echo "  ];"
    echo '}'
}
