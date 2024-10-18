{
  lib,
  stdenvNoCC,
  fetchLapcePlugin,
  zstd,
}:

{
  author,
  name,
  version,
  hash,
  meta ? { },
  ...
}@args:

stdenvNoCC.mkDerivation (
  {
    pname = "lapce-plugin-${author}-${name}";
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

    meta = {
      sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    } // builtins.removeAttrs meta [ "sourceProvenance" ];
  }
  // builtins.removeAttrs args [
    "pluginName"
    "version"
    "hash"
    "meta"
  ]
)
