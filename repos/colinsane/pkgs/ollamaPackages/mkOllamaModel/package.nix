# TODO: replace this with ollama-model-direct-download?
# - <https://github.com/NixOS/nixpkgs/pull/418967>
{
  fetchurl,
  jq,
  lib,
  stdenvNoCC,
}:
{
  modelName,
  variant,
  owner ? "library",
  manifestHash ? "",
  # grab the *Blob from the manifest (trim the `sha256:` prefix).
  # the manifest can be acquired by providing just the above parameters and building this package, then viewing the output
  modelBlob ? "",
  modelBlobHash ? "",
  paramsBlob ? "",
  paramsBlobHash ? "",
  systemBlob ? "",
  systemBlobHash ? "",
}:
let
  longModelName = "${modelName}-${variant}";
in
stdenvNoCC.mkDerivation {
  name = longModelName;
  srcs = [
    (fetchurl {
      name = "${longModelName}/manifest";
      url = "https://registry.ollama.ai/v2/${owner}/${modelName}/manifests/${variant}";
      hash = manifestHash;
    })
  ] ++ lib.optionals (modelBlob != "") [
    (fetchurl {
      name = "${longModelName}/model-blob";
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${modelBlob}";
      hash = modelBlobHash;
    })
  ] ++ lib.optionals (paramsBlob != "") [
    (fetchurl {
      name = "${longModelName}/params-blob";
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${paramsBlob}";
      hash = paramsBlobHash;
    })
  ] ++ lib.optionals (systemBlob != "") [
    (fetchurl {
      name = "${longModelName}/system-blob";
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${systemBlob}";
      hash = systemBlobHash;
    })
  ];

  nativeBuildInputs = [
    jq
  ];

  unpackPhase = ''
    runHook preUnpack

    # unpack all the name-hashed sources to have names more easy to work with:
    # - manifest
    # - model-blob
    # - ...
    for _src in $srcs; do
      _longSrcName=$(stripHash "$_src")
      _srcName="''${_longSrcName/${longModelName}-/}"
      ln -s "$_src" "$_srcName"
    done

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    mkdir blobs
    ${lib.optionalString (modelBlob != "") ''
      mv model-blob blobs/sha256-${modelBlob}
    ''}
    ${lib.optionalString (paramsBlob != "") ''
      mv params-blob blobs/sha256-${paramsBlob}
    ''}
    ${lib.optionalString (systemBlob != "") ''
      mv system-blob blobs/sha256-${systemBlob}
    ''}

    # lots of fields are not required by ollama,
    # and removing them allows to also remove the files (hashes) they reference
    jq 'del(.config)' < manifest \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.ollama.image.license")) }' \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.ollama.image.template")) }' \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.docker.container.image.v1+json")) }' \
    > manifest.new
    mv manifest.new manifest

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/$manifestDir $(dirname $out/$blobDir)
    cp manifest $out/$manifestDir/$variant
    cp -R blobs $out/$blobDir

    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck

    # diagnostics for when packaging models: use the manifestBlob, systemBlob output here in your nix expression
    echo "manifest:"
    cat manifest

    mismatchedBlobs=()
    checkBlob() {
      local blobType="$1"
      local expectedBlobHash="$2"
      local blobHash=$(cat manifest | jq ".layers.[] | select(.mediaType == \"application/vnd.ollama.image.$blobType\") | .digest[7:]")
      local blobHashNoQuotes=''${blobHash//\"/}

      if [ -n "$blobHash" ]; then
        printf "  %sBlob = %s;\n" "$blobType" "$blobHash"
      fi

      if [ -n "$expectedBlobHash" -a ! -e "blobs/sha256-$blobHashNoQuotes" ]; then
        printf "  %sBlob doesn't exist at blobs/sha256-$blobHashNoQuotes\n"
        mismatchedBlobs+=("$blobType")
      fi

      if [ "$blobHashNoQuotes" != "$expectedBlobHash" ]; then
        mismatchedBlobs+=("$blobType")
      fi
    }

    echo "blobs:"
    checkBlob model "$modelBlob"
    checkBlob params "$paramsBlob"
    checkBlob system "$systemBlob"
    checkBlob ensureDoesntFailForNonExistentBlob

    if [ -n "$mismatchedBlobs" ]; then
      echo "mismatched blobs:"
      for b in "''${mismatchedBlobs[@]}"; do
        echo "- $b"
      done
      false
    fi

    runHook postCheck
  '';

  doCheck = true;

  env = {
    blobDir = "share/ollama/models/blobs";
    manifestDir = "share/ollama/models/manifests/registry.ollama.ai/library/${modelName}";
    inherit variant modelBlob paramsBlob systemBlob;
  };

  meta = {
    homepage = "https://ollama.com/${owner}/${modelName}";
  };
}
