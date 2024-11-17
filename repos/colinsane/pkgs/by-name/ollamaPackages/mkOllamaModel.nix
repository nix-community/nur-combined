{
  fetchurl,
  jq,
  lib,
  stdenv,
}:
{
  modelName,
  variant,
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
stdenv.mkDerivation {
  name = modelName;
  srcs = [
    (fetchurl {
      url = "https://registry.ollama.ai/v2/library/${modelName}/manifests/${variant}";
      hash = manifestHash;
    })
  ] ++ lib.optionals (modelBlob != "") [
    (fetchurl {
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${modelBlob}";
      hash = modelBlobHash;
    })
  ] ++ lib.optionals (paramsBlob != "") [
    (fetchurl {
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${paramsBlob}";
      hash = paramsBlobHash;
    })
  ] ++ lib.optionals (systemBlob != "") [
    (fetchurl {
      url = "https://registry.ollama.ai/v2/llama/${modelName}:${variant}/blobs/sha256-${systemBlob}";
      hash = systemBlobHash;
    })
  ];

  nativeBuildInputs = [
    jq
  ];

  unpackPhase = ''
    runHook preUnpack

    for _src in $srcs; do
      _srcName=$(stripHash "$_src")
      ln -s "$_src" "$_srcName"
    done

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    mkdir blobs
    for _src in sha256-*; do
      mv "$_src" blobs
    done

    # lots of fields are not required by ollama,
    # and removing them allows to also remove the files (hashes) they reference
    jq 'del(.config)' < ${variant} \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.ollama.image.license")) }' \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.ollama.image.template")) }' \
    | jq '. + { layers: .layers | map(select(.mediaType != "application/vnd.docker.container.image.v1+json")) }' \
    > manifest

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/$manifestDir $(dirname $out/$blobDir)
    cp manifest $out/$manifestDir/$variant
    cp -R blobs $out/$blobDir

    runHook postInstall
  '';

  env.blobDir = "share/ollama/models/blobs";
  env.manifestDir = "share/ollama/models/manifests/registry.ollama.ai/library/${modelName}";
  env.variant = variant;
}
