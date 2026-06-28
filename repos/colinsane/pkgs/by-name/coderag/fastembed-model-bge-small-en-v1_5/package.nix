{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  # HuggingFace cache layout used by fastembed: blobs named by sha256, symlinked into
  # snapshots/<revision>/, with refs/main pointing at the revision.
  #
  # Files below correspond to qdrant/bge-small-en-v1.5-onnx-q @ commit
  # 52398278842ec682c6f32300af41344b1c0b0bb2, which is what fastembed fetches when asked
  # for the default CodeRAG model ("BAAI/bge-small-en-v1.5" via the qdrant ONNX mirror).
  revision = "52398278842ec682c6f32300af41344b1c0b0bb2";
  blobs = {
    config_json = {
      sha256 = "13582bcf2effc85b7bf3d3f5532e686bc1c9ce86bb009d10f0ec33cbe92299dd";
      hash = "sha256-E1grzy7/yFt789P1Uy5oa8HJzoa7AJ0Q8Owzy+kimd0=";
      file = "config.json";
    };
    tokenizer_json = {
      sha256 = "d241a60d5e8f04cc1b2b3e9ef7a4921b27bf526d9f6050ab90f9267a1f9e5c66";
      hash = "sha256-0kGmDV6PBMwbKz6e96SSGye/Um2fYFCrkPkmeh+eXGY=";
      file = "tokenizer.json";
    };
    tokenizer_config_json = {
      sha256 = "0b29c7bfc889e53b36d9dd3e686dd4300f6525110eaa98c76a5dafceb2029f53";
      hash = "sha256-CynHv8iJ5Ts22d0+aG3UMA9lJREOqpjHal2vzrICn1M=";
      file = "tokenizer_config.json";
    };
    special_tokens_map_json = {
      sha256 = "5d5b662e421ea9fac075174bb0688ee0d9431699900b90662acd44b2a350503a";
      hash = "sha256-XVtmLkIeqfrAdRdLsGiO4NlDFpmQC5BmKs1EsqNQUDo=";
      file = "special_tokens_map.json";
    };
    model_optimized_onnx = {
      sha256 = "51f1bd0addd6e859e42c2c8021a5e5461385bb676a649f4b269aa445449f2431";
      hash = "sha256-UfG9Ct3W6FnkLCyAIaXlRhOFu2dqZJ9LJpqkRUSfJDE=";
      file = "model_optimized.onnx";
    };
  };

  fetchBlob = name: { sha256, hash, file }:
    fetchurl {
      url = "https://huggingface.co/qdrant/bge-small-en-v1.5-onnx-q/resolve/${revision}/${file}";
      inherit hash;
      name = file;
    };

  fetchedBlobs = lib.mapAttrs fetchBlob blobs;
in

stdenvNoCC.mkDerivation {
  pname = "fastembed-model-bge-small-en-v1.5";
  version = "1.5";

  srcs = [];
  unpackPhase = ":";

  allowSubstitutes = false;

  buildPhase = ''
    mkdir -p "$out/models--qdrant--bge-small-en-v1.5-onnx-q/blobs"
    mkdir -p "$out/models--qdrant--bge-small-en-v1.5-onnx-q/snapshots/${revision}"
    mkdir -p "$out/models--qdrant--bge-small-en-v1.5-onnx-q/refs"

    echo -n "${revision}" > "$out/models--qdrant--bge-small-en-v1.5-onnx-q/refs/main"

    # The files_metadata.json is not strictly needed by fastembed at runtime, but we
    # reproduce it to make the cache directory look exactly like the one fastembed creates.
    cat > "$out/models--qdrant--bge-small-en-v1.5-onnx-q/files_metadata.json" <<EOF
    {
      "snapshots/${revision}/config.json": {"size": 706, "blob_id": "0d7726d0cdccb62ee17c03bd1595cff07199b8f8"},
      "snapshots/${revision}/tokenizer_config.json": {"size": 1242, "blob_id": "75305659f7795d4549f0e23688b52fa20a32f925"},
      "snapshots/${revision}/special_tokens_map.json": {"size": 695, "blob_id": "9bbecc17cabbcbd3112c14d6982b51403b264bfa"},
      "snapshots/${revision}/tokenizer.json": {"size": 711396, "blob_id": "688882a79f44442ddc1f60d70334a7ff5df0fb47"},
      "snapshots/${revision}/model_optimized.onnx": {"size": 66465124, "blob_id": "${blobs.model_optimized_onnx.sha256}"}
    }
    EOF
  '';

  installPhase = ''
    runHook preInstall

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: { sha256, ... }: ''
      install -Dm444 "${fetchedBlobs.${name}}" "$out/models--qdrant--bge-small-en-v1.5-onnx-q/blobs/${sha256}"
    '') blobs)}

    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: { sha256, file, ... }: ''
      ln -s "../../blobs/${sha256}" "$out/models--qdrant--bge-small-en-v1.5-onnx-q/snapshots/${revision}/${file}"
    '') blobs)}

    mkdir -p "$out/models--qdrant--bge-small-en-v1.5-onnx-q/.locks"
    touch "$out/CACHEDIR.TAG"

    runHook postInstall
  '';

  meta = {
    description = "Fastembed/ONNX cache for the BAAI/bge-small-en-v1.5 embedding model";
    homepage = "https://huggingface.co/qdrant/bge-small-en-v1.5-onnx-q";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    # The upstream license is MIT. HuggingFace model weights derived from BAAI/bge-small-en-v1.5 (MIT).
  };
}