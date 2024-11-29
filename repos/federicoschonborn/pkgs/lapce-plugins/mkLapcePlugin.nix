{
  lib,
  stdenvNoCC,
  fetchLapcePlugin,
  zstd,
}:

{
  author,
  cleanAuthor ? builtins.replaceStrings [ " " ] [ "-" ] author,
  name,
  cleanName ? builtins.replaceStrings [ " " ] [ "-" ] name,
  version,
  hash,
  wasm ? true,
  meta ? { },
  ...
}@args:

stdenvNoCC.mkDerivation (
  {
    pname = "lapce-plugin-${cleanAuthor}-${cleanName}";
    inherit version;

    src = fetchLapcePlugin {
      inherit
        author
        name
        version
        hash
        ;
    };

    nativeBuildInputs = [ zstd ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir $out
      tar xvf $src -C $out

      runHook postInstall
    '';

    meta = lib.mergeAttrsList [
      # Default values.
      {
        homepage = "https://plugins.lapce.dev/plugins/${author}/${name}";
      }

      # Set sourceProvenance if the plugin contains a WASM binary.
      (lib.optionalAttrs wasm {
        sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
      })

      # Finally, merge the user's meta attributes.
      meta
    ];
  }
  // builtins.removeAttrs args [
    "author"
    "cleanAuthor"
    "name"
    "cleanName"
    "version"
    "hash"
    "wasm"
    "meta"
  ]
)
