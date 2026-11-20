{
  lib,
  autoAddDriverRunpath,
  cmake,
  cudaPackages,
  fetchFromGitHub,
  git,
  makeWrapper,
  ninja,
  python3,
  stdenv,
  symlinkJoin,
}:

let
  version = "1.1.68";
  cudaCapabilities = cudaPackages.backendStdenv.cudaCapabilities;
  cudaArchitectures = lib.concatMapStringsSep ";" (lib.replaceStrings
    [ "." ]
    [ "" ]
  ) cudaCapabilities;
  sm70 = lib.any (capability: lib.versionAtLeast capability "7.0") cudaCapabilities;
  preSm70 = lib.any (capability: lib.versionOlder capability "7.0") cudaCapabilities;
  targets = [
    "maya"
  ]
  ++ lib.optional (cudaCapabilities == [ ] || !preSm70) "maya-ds4"
  ++ lib.optional (cudaCapabilities == [ ] || sm70) "maya-mm3";
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
    ps.jsonschema
    ps.textual
  ]);
  runtimeTools = [
    cmake
    ninja
    git
    cudaPackages.cuda_nvcc
    stdenv.cc
  ];
  hydrateScript = ''
    dest="''${XDG_DATA_HOME:-''$HOME/.local/share}/project-maya"
    ${lib.getExe python3} "${placeholder "out"}/libexec/project-maya/hydrate.py" \
      "${placeholder "out"}/share/project-maya" "$dest"
  '';
  unwrapped = cudaPackages.backendStdenv.mkDerivation (finalAttrs: {
    pname = "project-maya";
    inherit version;
    src = fetchFromGitHub {
      owner = "mw00";
      repo = "project-maya";
      tag = "v${finalAttrs.version}";
      hash = "sha256-rIk3AkUC96YuYNbBykc5Ld+ktqx0nrk+2Otac5Qmx5o=";
    };

    __structuredAttrs = true;
    strictDeps = true;

    patches = [ ./nix-pip.patch ];

    env.NVCC_PREPEND_FLAGS = "-I${cudaPackages.cuda_profiler_api.include}/include -I${cudaPackages.nvtx.include}/include";

    nativeBuildInputs = [
      cmake
      ninja
      git
      cudaPackages.cuda_nvcc
      python3
      autoAddDriverRunpath
      makeWrapper
    ];

    buildInputs = [
      cudaPackages.cccl
      cudaPackages.cuda_cudart
      cudaPackages.libcublas
      cudaPackages.cuda_profiler_api.include
      cudaPackages.nvtx.include
    ];

    postPatch = ''
      cp -a ${llamaSrc} third_party/llama.cpp
      chmod -R u+w third_party/llama.cpp
      ${lib.getExe python3} tools/vision/glm5next_patch.py third_party/llama.cpp
    '';

    cmakeFlags = [
      (lib.cmakeBool "STRATA_ENABLE_CUDA" true)
      (lib.cmakeBool "STRATA_BUILD_TESTS" false)
      (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaArchitectures)
    ];

    preConfigure = ''
      cmakeFlagsArray+=("-DSTRATA_GGML_DIR=$PWD/third_party/llama.cpp")
    '';

    ninjaFlags = targets;

    postBuild = ''
      cmake -S "$cmakeDir/tools/vision" -B "$cmakeDir/build-vision" -G Ninja \
        ${lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release"} \
        ${lib.cmakeFeature "LLAMA_DIR" "$(realpath $cmakeDir)/third_party/llama.cpp"} \
        ${lib.cmakeBool "STRATA_VISION_CUDA" true} \
        ${lib.escapeShellArg (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaArchitectures)}
      cmake --build "$cmakeDir/build-vision" --target maya-vision -j "$NIX_BUILD_CORES"
    '';

    installPhase = ''
      runHook preInstall

      cd "$cmakeDir"

      mkdir -p "$out/share/project-maya"
      cp -a . "$out/share/project-maya"
      chmod -R u+w "$out/share/project-maya"
      rm -rf "$out/share/project-maya/build" "$out/share/project-maya/build-vision"

      install -Dm755 build/maya "$out/share/project-maya/build/maya"
      ${lib.optionalString (builtins.elem "maya-ds4" targets) ''
        install -Dm755 build/maya-ds4 "$out/share/project-maya/build/maya-ds4"
      ''}
      ${lib.optionalString (builtins.elem "maya-mm3" targets) ''
        install -Dm755 build/maya-mm3 "$out/share/project-maya/build/maya-mm3"
      ''}
      install -Dm755 build-vision/bin/maya-vision "$out/share/project-maya/build-vision/bin/maya-vision"
      install -Dm644 ${./hydrate.py} "$out/libexec/project-maya/hydrate.py"

      cd "$out/share/project-maya"
      python3 - <<'PYEOF'
      import json
      import setup

      archs = [int(a) for a in "${cudaArchitectures}".split(";")]
      with open("build/MAYA-BUILD.json", "w", encoding="utf-8") as f:
          json.dump({
              "src": setup.source_hash(setup.ENGINE_SOURCES),
              "archs": archs,
              "targets": ${builtins.toJSON targets},
          }, f, indent=1)
      with open("build-vision/MAYA-BUILD.json", "w", encoding="utf-8") as f:
          json.dump({
              "src": setup.source_hash(("tools/vision",)),
              "archs": archs,
              "backend": "cuda",
          }, f, indent=1)
      PYEOF
      rm -rf __pycache__

      makeWrapper ${lib.getExe python3} "$out/bin/maya" \
        --run ${lib.escapeShellArg hydrateScript} \
        --set MAYA_SH 1 \
        --set MAYA_NO_PIP 1 \
        --add-flags '"''$dest/maya.py"'

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      ${lib.getExe python3} ${./test-hydrate.py} "$out/libexec/project-maya/hydrate.py"
      cd "$out/share/project-maya"
      ${lib.getExe python3} - <<'PYEOF'
      import json
      import setup

      for stamp, parts in (("build/MAYA-BUILD.json", setup.ENGINE_SOURCES),
                           ("build-vision/MAYA-BUILD.json", ("tools/vision",))):
          with open(stamp, encoding="utf-8") as f:
              assert json.load(f)["src"] == setup.source_hash(parts), stamp
      PYEOF
      runHook postInstallCheck
    '';

    passthru.llamaSrc = llamaSrc;

    passthru.updateScript = [ (toString ./update.sh) ];

    meta = {
      description = "Local large language model inference stack with CUDA engines and a self-managed data folder";
      homepage = "https://github.com/mw00/project-maya";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.xddxdd ];
      mainProgram = "maya";
      platforms = lib.platforms.linux;
    };
  });
in
symlinkJoin {
  pname = "project-maya";
  inherit version;
  __structuredAttrs = false;
  strictDeps = true;

  paths = [ unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/maya" \
      --prefix PYTHONPATH : "${pythonEnv}/${python3.sitePackages}" \
      --prefix PATH : "${lib.makeBinPath runtimeTools}" \
      --suffix PATH : "/run/opengl-driver/bin"
    PYTHONPATH="${pythonEnv}/${python3.sitePackages}:$out/share/project-maya" \
      ${lib.getExe pythonEnv} -c \
      'import numpy, jinja2, regex, yaml, tqdm, requests, PIL, psutil, jsonschema, setup'
  '';

  inherit (unwrapped) src meta;
  passthru = unwrapped.passthru // {
    inherit unwrapped;
  };
}
