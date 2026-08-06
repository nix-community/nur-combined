{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  curl,
  gnused,
  apple-sdk_26,
  darwinMinVersionHook,
  nix-update,
  writeShellScript,
}:
let
  # ds4 loads Metal shader sources at runtime, looking them up relative to the
  # current directory unless these env overrides are set (see ds4_metal.m,
  # ds4_gpu_full_source). The wrappers point each one into the store.
  metalSources = {
    DS4_METAL_FLASH_ATTN_SOURCE = "flash_attn.metal";
    DS4_METAL_DENSE_SOURCE = "dense.metal";
    DS4_METAL_MOE_SOURCE = "moe.metal";
    DS4_METAL_DSV4_HC_SOURCE = "dsv4_hc.metal";
    DS4_METAL_UNARY_SOURCE = "unary.metal";
    DS4_METAL_DSV4_KV_SOURCE = "dsv4_kv.metal";
    DS4_METAL_DSV4_ROPE_SOURCE = "dsv4_rope.metal";
    DS4_METAL_DSV4_MISC_SOURCE = "dsv4_misc.metal";
    DS4_METAL_ARGSORT_SOURCE = "argsort.metal";
    DS4_METAL_CPY_SOURCE = "cpy.metal";
    DS4_METAL_CONCAT_SOURCE = "concat.metal";
    DS4_METAL_GET_ROWS_SOURCE = "get_rows.metal";
    DS4_METAL_SUM_ROWS_SOURCE = "sum_rows.metal";
    DS4_METAL_SOFTMAX_SOURCE = "softmax.metal";
    DS4_METAL_REPEAT_SOURCE = "repeat.metal";
    DS4_METAL_GLU_SOURCE = "glu.metal";
    DS4_METAL_NORM_SOURCE = "norm.metal";
    DS4_METAL_BIN_SOURCE = "bin.metal";
    DS4_METAL_SET_ROWS_SOURCE = "set_rows.metal";
  };

  metalSourceWrapperArgs = lib.concatStringsSep " " (
    lib.mapAttrsToList (envName: fileName: "--set ${envName} \"$out/share/ds4/metal/${fileName}\"") metalSources
  );
in
stdenv.mkDerivation {
  pname = "ds4";
  version = "0-unstable-2026-06-17";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "ds4";
    rev = "80ebbc396aee40eedc1d829222f3362d10fa4c6c";
    hash = "sha256-Ieuc72GHZs20ModQfnvI5Me31n4Pj+WFYtsuqaKJceo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    # MTLResidencySet needs SDK >= 15, the Metal 4 tensor API probe needs
    # SDK >= 26 (compile-time gated on __MAC_OS_X_VERSION_MAX_ALLOWED).
    apple-sdk_26
    (darwinMinVersionHook "26.0")
  ];

  dontConfigure = true;
  enableParallelBuilding = true;

  # NATIVE_CPU_FLAG defaults to -mcpu=native, which is impure; the heavy
  # lifting happens on the GPU anyway.
  makeFlags = [ "NATIVE_CPU_FLAG=" ];

  installPhase = ''
    runHook preInstall

    for bin in ds4 ds4-server ds4-bench ds4-eval ds4-agent; do
      install -Dm755 "$bin" "$out/bin/$bin-unwrapped"
      makeWrapper "$out/bin/$bin-unwrapped" "$out/bin/$bin" \
        ${metalSourceWrapperArgs}
    done

    mkdir -p "$out/share/ds4"
    cp -R metal "$out/share/ds4/"
    install -Dm644 README.md "$out/share/ds4/README.md"
    install -Dm644 LICENSE "$out/share/ds4/LICENSE"
    install -Dm644 MODEL_CARD.md "$out/share/ds4/MODEL_CARD.md"

    # Model downloader: by default the script stores GGUFs next to itself,
    # which is read-only in the store. Default to a per-user data directory
    # instead (the same place the ds4 darwin module looks for models).
    install -Dm755 download_model.sh "$out/bin/ds4-download-model"
    substituteInPlace "$out/bin/ds4-download-model" \
      --replace-fail 'ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)' \
                     'ROOT=''${DS4_ROOT:-$HOME/.local/share/ds4}; mkdir -p "$ROOT"'
    patchShebangs "$out/bin/ds4-download-model"
    wrapProgram "$out/bin/ds4-download-model" \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          curl
          gnused
        ]
      }"

    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake ds4 --version=branch";

  meta = {
    description = "DwarfStar: DeepSeek V4 Flash and PRO local inference engine (Metal build)";
    homepage = "https://github.com/antirez/ds4";
    license = lib.licenses.mit;
    mainProgram = "ds4";
    maintainers = [ lib.maintainers.aciceri ];
    platforms = [ "aarch64-darwin" ];
  };
}
