{
  fetchurl,
  lib,
  linkFarm,
  python3,
  src,
  stdenv,
  version,
  zstd,
}:
let
  artifacts = lib.importJSON ./artifacts.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock-firmware";
  inherit src version;
  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    python3
    zstd
  ];
  dontConfigure = true;
  dontPatchELF = true;
  dontStrip = true;
  buildPhase = ''
    runHook preBuild
    make firmware INPUTS=${
      linkFarm "gpu-unlock-inputs" (
        map (artifact: {
          name = artifact.filename;
          path = fetchurl {
            inherit (artifact) url sha256;
          };
        }) artifacts
      )
    } ASSETS="$PWD/assets"
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    make test ASSETS="$PWD/assets"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 -t "$out/lib/firmware/gpu-unlock/${lib.removeSuffix ".tar.xz" (lib.removePrefix "NVIDIA-kernel-module-source-" (builtins.head artifacts).filename)}" assets/*.bin
    install -Dm644 -t "$out/share/licenses/gpu-unlock-firmware" \
      assets/NVIDIA-LICENSE firmware/NOTICE.md licenses/*
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    python3 - "$out" "${finalAttrs.src}/firmware" <<'PY'
    import hashlib
    import json
    from pathlib import Path
    import sys

    directory, = Path(sys.argv[1]).glob("lib/firmware/gpu-unlock/*")
    manifest, = Path(sys.argv[2]).glob("artifacts-*.json")
    metadata = json.loads(manifest.read_text())
    expected = metadata["derived_assets"] | {
        "gsp_ga10x.bin": metadata["source_artifacts"][2]["firmware"][0]["sha256"],
        f"v67-ga102-{directory.name}.bin": metadata["generated_payload"]["sha256"],
    }
    assert {path.name for path in directory.iterdir()} == set(expected)
    for name, digest in expected.items():
        with (directory / name).open("rb") as stream:
            assert hashlib.file_digest(stream, "sha256").hexdigest() == digest, name
        print(f"verified installed firmware: {name}")
    PY
    runHook postInstallCheck
  '';

  meta = {
    description = "Pinned NVIDIA firmware and generated payload for gpu-unlock";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = [
      lib.licenses.unfree
      lib.licenses.gpl2Only
    ];
    sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
    maintainers = [ lib.maintainers.xddxdd ];
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };
})
