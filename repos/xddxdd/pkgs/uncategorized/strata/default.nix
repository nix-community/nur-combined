{
  lib,
  autoAddDriverRunpath,
  cmake,
  cudaArchitectures ? "75;80;86;89;120",
  cudaPackages_13,
  fetchFromGitHub,
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
  ];

  buildInputs = [
    cudaPackages_13.cccl
    cudaPackages_13.cuda_cudart
    cudaPackages_13.libcublas
  ];

  env.CUDA_ARCHS = cudaArchitectures;

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

        mkdir -p "$out/share/strata/engine" "$out/bin"
        cp ./build/strata "$out/share/strata/engine/strata"
        chmod 755 "$out/share/strata/engine/strata"

        rm -rf ./build
        mkdir -p "$out/share/strata"
        cp -a . "$out/share/strata/"
        rm -rf "$out/share/strata/build"

        sed -i -e '/^cmake==/d' -e '/^ninja==/d' "$out/share/strata/requirements.txt"

        cd "$out/share/strata"
        CUDA_ARCHS="$CUDA_ARCHS" STRATA_VERSION="${finalAttrs.version}" python3 - <<'PYEOF'
    import json
    import os
    import setup

    meta = {
        "source": "local",
        "version": os.environ["STRATA_VERSION"],
        "archs": [int(a) for a in os.environ["CUDA_ARCHS"].split(";")],
        "vision": "none",
        "cuda": 13,
        "src": setup.source_hash(setup.ENGINE_SOURCES),
    }
    with open(os.path.join("engine", "BUILD.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1)
    f2 = open(os.path.join("engine", "BUILD.json"), encoding="utf-8")
    assert json.load(f2)["src"] == setup.source_hash(setup.ENGINE_SOURCES)
    print("BUILD.json src hash verified:", meta["src"])
    PYEOF

        rm -rf "$out/share/strata/__pycache__"

        cat > "$out/bin/strata" <<'WEOF'
    #!/usr/bin/env bash
    set -euo pipefail
    dest="''${XDG_DATA_HOME:-''$HOME/.local/share}/strata"
    if [[ ! -f "$dest/.nix-store-version" || "''$(cat "$dest/.nix-store-version")" != "@version@" ]]; then
      rm -rf "$dest"
      cp -a "@out@/share/strata/" "$dest/"
      chmod -R u+w "$dest"
      echo "@version@" > "$dest/.nix-store-version"
    fi
    export STRATA_EXECV=1
    exec "@python@/bin/python" "$dest/setup.py" "$@"
    WEOF
        cat > "$out/bin/strata-chat" <<'WEOF'
    #!/usr/bin/env bash
    set -euo pipefail
    dest="''${XDG_DATA_HOME:-''$HOME/.local/share}/strata"
    if [[ ! -f "$dest/.nix-store-version" || "''$(cat "$dest/.nix-store-version")" != "@version@" ]]; then
      rm -rf "$dest"
      cp -a "@out@/share/strata/" "$dest/"
      chmod -R u+w "$dest"
      echo "@version@" > "$dest/.nix-store-version"
    fi
    export STRATA_EXECV=1
    exec "@python@/bin/python" "$dest/chat.py" "$@"
    WEOF
        for f in "$out/bin/strata" "$out/bin/strata-chat"; do
          chmod 755 "$f"
          sed -i -e "s|@out@|$out|g" -e "s|@python@|${pythonEnv}|g" -e "s|@version@|${finalAttrs.version}|g" "$f"
        done

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
