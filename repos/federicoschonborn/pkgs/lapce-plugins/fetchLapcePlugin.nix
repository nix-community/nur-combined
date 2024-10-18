{
  runCommand,
  cacert,
  curl,
}:

{
  author,
  name,
  version,
  hash,
}:

runCommand "lapce-plugin-${author}-${name}-${version}.volt"
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
    curl $(curl https://plugins.lapce.dev/api/v1/plugins/${author}/${name}/${version}/download) -o $out
  ''
