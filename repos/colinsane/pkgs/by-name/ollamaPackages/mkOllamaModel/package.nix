# TODO: replace this with ollama-model-direct-download?
# - <https://github.com/NixOS/nixpkgs/pull/418967>
#
# IF USING HUGGINGFACE:
# - the model must be "GGUF" format.
#   if not, the api will return a json error saying as much (as this api is llama-cpp flavored).
# - `variant` represents the quantization format (and is sometimes called "tag" by hf?).
#   find this on the right hand side of the hf model page.
#   examples: `Q4_0`, `Q2_K`, `BF16`
#
# QUANTIZATION SCHEMES:
# - Q4: 4 bits per weight
# - Q4_K: 4 bits per weight, but with k-means clustering.
#   - weights are grouped into superblocks of 8 or 16.
#   - each superblock has a single scale (usually 6 bit quantized?), and each weight within it is multiplied by it during expansion.
# - Q4_K_{S,M,L}: variants on Q4_K optimized for Small, Medium, or Large models.
# ...
# - K-type quantizations introduced here: <https://github.com/ggml-org/llama.cpp/pull/1684>
#   - "GGML_TYPE_Q4_K: type-1: 4-bit quantization in super-blocks containing 8 blocks, each block having 32 weights. Scales and mins are quantized with 6 bits. This ends up using 4.5 bpw."
#   - "LLAMA_FTYPE_MOSTLY_Q4_K_M - uses GGML_TYPE_Q6_K for half of the attention.wv and feed_forward.w2 tensors, else GGML_TYPE_Q4_K"
{
  fetchurl,
  jq,
  lib,
  stdenvNoCC,
}:
{
  modelName,
  variant,  # default: Q4_K_M ?
  owner ? "library",
  manifestHash ? "",
  # grab the *Blob from the manifest (trim the `sha256:` prefix).
  # the manifest can be acquired by providing just the above parameters and building this package, then viewing the output
  modelBlob ? "",
  paramsBlob ? "",
  systemBlob ? "",
  # mediaType: application/vnd.ollama.image.projector
  # projector is a separate model, which projects some other media type (e.g. image) into the same token space used by the main model (?).
  # more info: <https://deepwiki.com/ollama/ollama/7.3-multimodal-and-vision-support>
  projectorBlob ? "",
}:
let
  longModelName = "${modelName}-${variant}";
  fetchComponent = { name, hash, component }: fetchurl {
    inherit name hash;
    urls = [
      "https://huggingface.co/v2/${owner}/${modelName}/${component}"
      "https://registry.ollama.ai/v2/${owner}/${modelName}/${component}"
    ];
  };
  fetchBlob = { type, blob }: fetchComponent {
    name = "${longModelName}/${type}-blob";
    component = "blobs/sha256:${blob}";
    hash = "sha256:${blob}";
  };
  manifest = fetchComponent {
    name = "${longModelName}/manifest";
    component = "manifests/${variant}";
    hash = manifestHash;
  };
  blobs = lib.mapAttrs
    (type: blob:
      if blob != "" then
        fetchBlob { inherit type blob; }
      else
        null
    )
    {
      model = modelBlob;
      params = paramsBlob;
      projector = projectorBlob;
      system = systemBlob;
    };
in
stdenvNoCC.mkDerivation {
  name = longModelName;
  srcs = [
    manifest
  ] ++ lib.filter (b: b != null) (lib.attrValues blobs);

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
    ${lib.optionalString (projectorBlob != "") ''
      mv projector-blob blobs/sha256-${projectorBlob}
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

    # diagnostics for when packaging models: use the modelBlob/systemBlob/etc output here in your nix expression
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

      if [ "$blobHashNoQuotes" != "$expectedBlobHash" ]; then
        printf "  %sBlob from manifest does not match that passed to mkOllamaPackage\n" "$blobType"
        mismatchedBlobs+=("$blobType")
      elif [ -n "$expectedBlobHash" -a ! -e "blobs/sha256-$blobHashNoQuotes" ]; then
        printf "  %sBlob doesn't exist at blobs/sha256-%s\n" "$blobType" "$blobHashNoQuotes"
        mismatchedBlobs+=("$blobType")
      fi
    }

    echo "blobs referenced by the manifest:"
    checkBlob model "$modelBlob"
    checkBlob params "$paramsBlob"
    checkBlob projector "$projectorBlob"
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
    inherit variant modelBlob paramsBlob projectorBlob systemBlob;
  };

  passthru = {
    inherit blobs manifest;
  };

  meta = {
    homepage = "https://ollama.com/${owner}/${modelName}";
  };
}
