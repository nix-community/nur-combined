{
  lib,
  autoAddDriverRunpath,
  cmake,
  cudaArchitectures ? "75;80;86;89;120",
  cudaPackages_13,
  fetchFromGitHub,
  makeWrapper,
  ninja,
  python3,
}:

let
  version = "0.1.41";
  llamaRev = "3cf03257f219afbe7334045ff7c6a06ac68c627d";
  llamaSrc = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    rev = llamaRev;
    hash = "sha256-SRGoXa+4ACBCB3eaG9XFYhMN1i0FyPEy9Rrer+dFGYI=";
  };
  pythonEnv = python3.withPackages (ps: [
    ps.numpy
    ps.jinja2
    ps.regex
    ps.pyyaml
    ps.tqdm
    ps.requests
    ps.pillow
    ps.psutil
  ]);
  hydrateScript = ''
    dest="''${XDG_DATA_HOME:-''$HOME/.local/share}/strata"
    if [[ ! -f "$dest/.nix-store-version" || "''$(< "$dest/.nix-store-version")" != "${version}" ]]; then
      rm -rf "$dest"
      cp -a "${placeholder "out"}/share/strata/" "$dest/"
      chmod -R u+w "$dest"
      echo "${version}" > "$dest/.nix-store-version"
    fi
  '';
in
cudaPackages_13.backendStdenv.mkDerivation (finalAttrs: {
  pname = "strata";
  inherit version;
  src = fetchFromGitHub {
    owner = "Niko1221";
    repo = "Strata";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WhoIwg8GgeG3jAXYLSjNoZyN3RZ3T3JhgJX57fM80eE=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  patches = [ ./pip-importable.patch ];

  nativeBuildInputs = [
    cmake
    ninja
    cudaPackages_13.cuda_nvcc
    pythonEnv
    autoAddDriverRunpath
    makeWrapper
  ];

  buildInputs = [
    cudaPackages_13.cccl
    cudaPackages_13.cuda_cudart
    cudaPackages_13.libcublas
  ];

  cmakeFlags = [
    (lib.cmakeBool "STRATA_ENABLE_CUDA" true)
    (lib.cmakeBool "STRATA_BUILD_TESTS" false)
    (lib.cmakeBool "STRATA_PORTABLE" false)
    (lib.cmakeFeature "STRATA_GGML_DIR" "${llamaSrc}")
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaArchitectures)
  ];

  ninjaFlags = [ "strata" ];

  installPhase = ''
    runHook preInstall

    cd "$cmakeDir"

    install -Dm755 build/strata "$out/share/strata/engine/strata"

    cp -a . "$out/share/strata/"
    rm -rf "$out/share/strata/build"

    sed -i -e '/^cmake==/d' -e '/^ninja==/d' "$out/share/strata/requirements.txt"

    # the engine copy's BUILD.json must carry the same src hash setup.py
    # recomputes at run time, or it recompiles the engine instead of using it
    cd "$out/share/strata"
    python3 - <<'PYEOF'
    import json
    import setup

    meta = {
        "source": "local",
        "version": "${finalAttrs.version}",
        "archs": [int(a) for a in "${cudaArchitectures}".split(";")],
        "vision": "none",
        "cuda": 13,
        "src": setup.source_hash(setup.ENGINE_SOURCES),
    }
    with open("engine/BUILD.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1)
    PYEOF
    rm -rf "$out/share/strata/__pycache__"

    # makeWrapper --run content is pasted verbatim into the generated wrapper, so
    # $dest there is expanded each time the wrapper runs
    makeWrapper ${lib.getExe pythonEnv} "$out/bin/strata" \
      --run ${lib.escapeShellArg hydrateScript} \
      --set STRATA_EXECV 1 \
      --add-flags '"''$dest/setup.py"'

    makeWrapper ${lib.getExe pythonEnv} "$out/bin/strata-chat" \
      --run ${lib.escapeShellArg hydrateScript} \
      --set STRATA_EXECV 1 \
      --add-flags '"''$dest/chat.py"'

    runHook postInstall
  '';

  passthru.llamaSrc = llamaSrc;

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "Local large language model inference stack with a CUDA engine and a self-managed data folder";
    homepage = "https://github.com/Niko1221/Strata";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.xddxdd ];
    mainProgram = "strata";
    platforms = lib.platforms.linux;
  };
})
