{
  stdenvNoCC,
  crane,
  cacert,
  src,
  pname,
  version,
}:
stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  inherit pname version;
  name = "${src.name}-images";
  inherit src;

  platforms = [
    "linux/amd64"
    "linux/arm64"
  ];

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = builtins.hashString "sha256" "${pname} ${version} ok\n";

  nativeBuildInputs = [
    crane
    cacert
  ];

  buildCommand = ''
    readarray -t images < <(grep -rh 'image:' "$src" | sed 's/.*image: *"\?\([^"]*\)"\?.*/\1/' | grep -v '^$' | sort -u)
    for image in "''${images[@]}"; do
      for platform in "''${platforms[@]}"; do
        crane manifest --platform "$platform" "$image" >/dev/null
      done
    done
    printf '%s %s ok\n' "$pname" "$version" >"$out"
  '';
}
