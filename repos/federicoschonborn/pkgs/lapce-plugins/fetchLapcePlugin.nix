{
  runCommand,
  cacert,
  curl,
}:

{
  author,
  cleanAuthor ? builtins.replaceStrings [ " " ] [ "-" ] author,
  urlAuthor ? builtins.replaceStrings [ " " ] [ "%20" ] author,
  name,
  cleanName ? builtins.replaceStrings [ " " ] [ "-" ] name,
  urlName ? builtins.replaceStrings [ " " ] [ "%20" ] name,
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
    set -euo pipefail

    # The /download endpoint returns a Cloudflare URL 🥴
    downloadURL="$(curl https://plugins.lapce.dev/api/v1/plugins/${urlAuthor}/${urlName}/${version}/download)"
    curl "$downloadURL" -o $out
  ''
