{
  runCommand,
  cacert,
  curl,
}:

{
  author,
  cleanAuthor ? builtins.replaceStrings [ " " ] [ "-" ] author,
  name,
  cleanName ? builtins.replaceStrings [ " " ] [ "-" ] name,
  version,
  hash,
}:

runCommand "lapce-plugin-${cleanAuthor}-${cleanName}-${version}.volt"
  {
    nativeBuildInputs = [
      cacert
      curl
    ];

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = hash;
  }
  ''
    # The /download endpoint returns a Cloudflare URL 🥴
    curl "$(curl https://plugins.lapce.dev/api/v1/plugins/${author}/${name}/${version}/download)" -o "$out"
  ''
