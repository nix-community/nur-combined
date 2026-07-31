{
  lib,
  stdenvNoCC,
  cacert,
  crane,
  yq,
  src,
  pname,
  version,
}:
stdenvNoCC.mkDerivation {
  inherit pname version;
  name = "${src.name}-images";

  __structuredAttrs = true;

  inherit src;

  platforms = [
    "linux/amd64"
    "linux/arm64"
  ];

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = builtins.hashString "sha256" "${pname} ${version} ok\n";
  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  nativeBuildInputs = [
    crane
    cacert
    yq
  ];

  buildCommand = ''
    imagesRaw=$(find "$src" \( -name '*.yaml' -o -name '*.yml' \) -exec yq -r '.. | .image? // empty | strings' {} + | sort -u)
    if [ -z "$imagesRaw" ]; then
      echo "no images found in $src" >&2
      exit 1
    fi
    readarray -t images <<<"$imagesRaw"
    for image in "''${images[@]}"; do
      for platform in "''${platforms[@]}"; do
        crane manifest --platform "$platform" "$image" >/dev/null
      done
    done
    printf '%s %s ok\n' "$pname" "$version" >"$out"
  '';
}
