{
  lib,
  stdenv,
  fetchzip,
  runCommand,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  python3,
  zip,
}:

let
  version = "6.1.6";

  upstreamSrc = fetchzip {
    url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/SourceCodeUseThisOne.zip";
    hash = "sha256-gby1WGY1MMpOXoeifNdaqVb9BDSquhM2cWKC1Z9dnlw=";
    stripRoot = false;
  };

  src = runCommand "sponsorblock-for-youtube-${version}-source" { } ''
        cp -r ${upstreamSrc} $out
        chmod -R u+w $out

        ${python3}/bin/python - <<PY
    import json
    from pathlib import Path

    path = Path("$out/package-lock.json")
    data = json.loads(path.read_text())

    def registry_tarball(name: str, version: str) -> str:
        if name.startswith("@"):
            _, pkg = name.split("/", 1)
            return f"https://registry.npmjs.org/{name}/-/{pkg}-{version}.tgz"
        return f"https://registry.npmjs.org/{name}/-/{name}-{version}.tgz"

    def should_patch(entry: dict) -> bool:
        version = entry.get("version", "")
        return (
            "resolved" not in entry
            and "integrity" in entry
            and isinstance(version, str)
            and version != ""
            and "://" not in version
            and not version.startswith(("file:", "git+", "github:", "workspace:"))
        )

    for pkg_path, entry in data.get("packages", {}).items():
        if not isinstance(entry, dict) or not pkg_path.startswith("node_modules/"):
            continue
        if should_patch(entry):
            name = pkg_path.rsplit("node_modules/", 1)[1]
            entry["resolved"] = registry_tarball(name, entry["version"])

    for name, entry in data.get("dependencies", {}).items():
        if not isinstance(entry, dict):
            continue
        if should_patch(entry):
            entry["resolved"] = registry_tarball(name, entry["version"])

    path.write_text(json.dumps(data, indent=2) + "\n")
    PY
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sponsorblock-for-youtube-firefox";
  inherit version src;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-YNfWlPR2YWAbDBWzdTX3cqbZL0wqMaif2G9Im5vx8zg=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    zip
  ];

  makeCacheWritable = true;
  npmFlags = [ "--ignore-scripts" ];

  postPatch = ''
    cp config.json.example config.json
  '';

  buildPhase = ''
    runHook preBuild

    npm run build:firefox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd dist > /dev/null
    zip -qr "$TMPDIR/sponsorblock.xpi" *
    popd > /dev/null

    install -Dm644 "$TMPDIR/sponsorblock.xpi" "$out/sponsorBlocker@ajay.app.xpi"
    ln -s sponsorBlocker@ajay.app.xpi "$out/sponsorblock.xpi"

    runHook postInstall
  '';

  passthru = {
    extid = "sponsorBlocker@ajay.app";
  };

  meta = {
    description = "SponsorBlock for YouTube Firefox add-on built from source";
    homepage = "https://github.com/ajayyy/SponsorBlock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
