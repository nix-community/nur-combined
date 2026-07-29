# Spektrafilm film & print data pack for the darktable spektrafilm module.
#
# The darktable spektrafilm IOP reads its spectral LUT + film/paper profiles at
# runtime from <darktable config dir>/spektrafilm/ :
#   pack.json, spectra_lut.f32, profiles/*.json
# (see sf_pack_dir() / dt_loc_get_user_config_dir() in src/iop/spektrafilm.c —
# it only looks in the user config dir, never in the install datadir).
#
# The July 29 PR commits switched the spectral upsampling LUT to the upstream
# float16 format, so the older published Arecsu zip is stale. Generate the pack
# reproducibly from this flake's pinned Python spektrafilm package and the
# exporter script posted in the pixls.us thread.
{
  lib,
  runCommand,
  fetchurl,
  python3,
  spektrafilm,
  darktableSpektrafilmRev ? "1a6bbf4c1cc0dac32311e67307e9ed1c1beaf6ff",
}:

let
  exporter = fetchurl {
    name = "spektrafilm_export_data-2026-07-29.py";
    url = "https://pixls-discuss.s3.dualstack.us-east-1.amazonaws.com/original/3X/0/d/0df15c93a547b6158c5935557832df23f0ffb5ab.py";
    hash = "sha256-bNzhceTxp303v/obGZVoLaFzXc2ShNqVFAyE+BDFMBs=";
  };

  pythonEnv = python3.withPackages (_: [ spektrafilm ]);
in
runCommand "spektrafilm-data-pack-${spektrafilm.version}"
  {
    nativeBuildInputs = [ pythonEnv ];
    passthru = {
      inherit darktableSpektrafilmRev exporter;
      exporterHash = "sha256-bNzhceTxp303v/obGZVoLaFzXc2ShNqVFAyE+BDFMBs=";
    };
  }
  ''
    export NUMBA_DISABLE_JIT=1
    export NUMBA_CACHE_DIR=$TMPDIR/numba-cache
    python ${exporter} -o "$out"

    python - "$out" <<'PY'
    import hashlib
    import json
    import pathlib
    import struct
    import sys

    out = pathlib.Path(sys.argv[1])
    pack = json.loads((out / "pack.json").read_text())
    if pack.get("spektrafilm_version") != "${spektrafilm.version}":
        raise SystemExit("unexpected spektrafilm_version in pack.json")

    profiles = sorted((out / "profiles").glob("*.json"))
    if len(profiles) < 30:
        raise SystemExit(f"unexpectedly few profiles: {len(profiles)}")

    lut_path = out / "spectra_lut.f32"
    data = lut_path.read_bytes()
    if data[:4] != b"SFS2":
        raise SystemExit("expected new SFS2 float16 LUT header")
    header_version = struct.unpack_from("<i", data, 4)[0]
    dims = struct.unpack_from("<iii", data, 8)
    dtype = struct.unpack_from("<i", data, 20)[0]
    if header_version != 2 or dtype != 1:
        raise SystemExit(f"unexpected LUT header: version={header_version} dtype={dtype}")
    if dims[0] != dims[1] or dims[2] < 70:
        raise SystemExit(f"unexpected LUT dimensions: {dims}")

    (out / "spectra_lut.f32.sha256").write_text(hashlib.sha256(data).hexdigest() + "\n")
    (out / "generated-darktable-rev").write_text("${darktableSpektrafilmRev}\n")
    (out / "exporter.sha256").write_text("sha256-bNzhceTxp303v/obGZVoLaFzXc2ShNqVFAyE+BDFMBs=\n")
    PY
  ''
