{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
  git,
  cacert,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix,
}:

let
  version = "0-unstable-2026-11-25";
  rev = "2a4ed5f8ee9b251420fd687bbce60e682645cb3c";

  src = fetchFromGitHub {
    owner = "Lakr233";
    repo = "vphone-cli";
    inherit rev;
    hash = "sha256-wy4iHgjakLCLOwWquIHTzOydsTOcBROO0xzKMwi5+Bo=";
  };

  # Upstream's workspace and the projects it invokes from build phases resolve
  # SwiftPM dependencies independently. Resolve the complete graph once, then
  # mirror those checkouts for every nested xcodebuild.
  spmDeps = stdenvNoCC.mkDerivation {
    pname = "vphone-cli-spm-deps";
    inherit version src;

    nativeBuildInputs = [
      git
      cacert
      python3
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;
    __noChroot = true;

    buildPhase = ''
      runHook preBuild

      export PATH="/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
      export GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt
      export CFFIXED_USER_HOME="$HOME"
      unset DEVELOPER_DIR SDKROOT

      xcodebuild -resolvePackageDependencies \
        -workspace VPhone.xcworkspace \
        -scheme VPhone \
        -clonedSourcePackagesDirPath "$out" \
        -derivedDataPath "$TMPDIR/derived" \
        -disableAutomaticPackageResolution \
        -onlyUsePackageVersionsFromResolvedFile \
        -skipMacroValidation \
        -skipPackagePluginValidation \
        -IDEPackageSupportDisableManifestSandbox=YES \
        -IDEPackageSupportDisablePluginExecutionSandbox=YES

      chmod -R u+w "$out"

      python3 - "$PWD" "$out" <<'PY'
      import json
      import os
      import sys
      from pathlib import Path

      source_root, output = sys.argv[1:]
      output_path = Path(output)

      state_path = output_path / "workspace-state.json"
      state = json.loads(state_path.read_text())
      state["object"]["artifacts"].sort(
          key=lambda item: (
              item.get("packageRef", {}).get("identity", ""),
              item.get("targetName", ""),
              item.get("path", ""),
          )
      )
      state["object"]["dependencies"].sort(
          key=lambda item: (
              item.get("packageRef", {}).get("identity", ""),
              item.get("packageRef", {}).get("location", ""),
          )
      )
      if isinstance(state["object"].get("prebuilts"), list):
          state["object"]["prebuilts"].sort(key=lambda item: json.dumps(item, sort_keys=True))
      state_path.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n")

      mirrors = []
      checkouts = output_path / "checkouts"
      for dependency in state["object"]["dependencies"]:
          package_ref = dependency["packageRef"]
          identity = package_ref["identity"]
          checkout = next(
              path for path in checkouts.iterdir() if path.name.casefold() == identity.casefold()
          )
          mirrors.append(
              {
                  "original": package_ref["location"],
                  "mirror": f"file://@SPM@/checkouts/{checkout.name}",
              }
          )
      (output_path / "mirrors.json").write_text(
          json.dumps({"object": mirrors, "version": 1}, indent=2, sort_keys=True) + "\n"
      )
      PY

      # SwiftPM's checkout Git metadata records clone timestamps and pack
      # ordering. Reduce each checkout to deterministic loose Git objects before
      # it is included in the fixed-output hash.
      mkdir -p "$out/.pack-inputs"
      for checkout in "$out/checkouts"/*; do
        repository=$(git -C "$checkout" config --get remote.origin.url)
        cp -a "$repository/objects/." "$checkout/.git/objects/"
        pack_inputs="$out/.pack-inputs/$(basename "$checkout")"
        mkdir -p "$pack_inputs"
        cp -a "$checkout/.git/objects/pack/." "$pack_inputs"/
        rm -rf "$checkout/.git/objects/pack" \
          "$checkout/.git/objects/info/alternates" \
          "$checkout/.git/objects/info/packs" \
          "$checkout/.git/objects/info/commit-graph" \
          "$checkout/.git/objects/info/commit-graphs" \
          "$checkout/.git/modules"
        for pack in "$pack_inputs"/*.pack; do
          [[ -e "$pack" ]] || continue
          git -C "$checkout" unpack-objects < "$pack"
        done
        GIT_CONFIG_NOSYSTEM=1 git -C "$checkout" prune --expire=now
        rm -rf "$checkout/.git/index" "$checkout/.git/logs" \
          "$checkout/.git/FETCH_HEAD" "$checkout/.git/ORIG_HEAD"
        find "$checkout" -name .git -type f -delete
      done
      rm -rf "$out/.pack-inputs"
      rm -rf "$out/repositories"

      python3 - "$PWD" "$out" <<'PY'
      import os
      import sys
      from pathlib import Path

      source_root, output = sys.argv[1:]

      def replace_text(path: Path) -> None:
          try:
              data = path.read_bytes()
          except (FileNotFoundError, PermissionError):
              return
          try:
              text = data.decode("utf-8")
          except UnicodeDecodeError:
              return
          replaced = text.replace(source_root, "@SRC@").replace(output, "@SPM@")
          if replaced != text:
              path.write_text(replaced)

      for root, directories, files in os.walk(output):
          for name in files:
              replace_text(Path(root) / name)
      PY

      runHook postBuild
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-UX3wHyScapDCNX3ZJnozf4YhOSykD0VTF5u4gFTj0XY=";

    meta = {
      description = "SwiftPM dependency cache for vphone-cli";
      platforms = [ "aarch64-darwin" ];
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vphone-cli";
  inherit version src;

  patches = [ ./xcode-26-compat.patch ];

  nativeBuildInputs = [
    makeWrapper
    python3
    writableTmpDirAsHomeHook
  ];

  # Xcode and its SDKs are host tools, so the package follows the existing
  # Xcode-backed Darwin derivations and disables the sandbox only on Darwin.
  __noChroot = stdenvNoCC.hostPlatform.isDarwin;

  dontConfigure = true;
  dontFixup = true;
  dontStrip = true;
  dontPatchShebangs = true;

  buildPhase = ''
    runHook preBuild

    spm="$PWD/.build/XcodeBundle/SourcePackages"
    mkdir -p "$spm"
    cp -a ${spmDeps}/. "$spm"/
    chmod -R u+w "$spm"

    python3 - "$PWD" "$spm" <<'PY'
    import os
    import sys
    from pathlib import Path

    source_root, spm = sys.argv[1:]

    for root, directories, files in os.walk(spm):
        for name in files:
            path = Path(root) / name
            try:
                text = path.read_text(encoding="utf-8")
            except (FileNotFoundError, PermissionError, UnicodeDecodeError):
                continue
            replaced = text.replace("@SRC@", source_root).replace("@SPM@", spm)
            if replaced != text:
                path.write_text(replaced, encoding="utf-8")
    PY

    export CFFIXED_USER_HOME="$HOME"

    unset SDKROOT DEVELOPER_DIR NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
    export SWIFTPM_MIRROR_CONFIG="$spm/mirrors.json"

    xcodebuild -workspace VPhone.xcworkspace \
      -scheme VPhone \
      -configuration Release \
      -destination 'platform=macOS,arch=arm64' \
      -derivedDataPath "$PWD/.build/XcodeBundle" \
      -clonedSourcePackagesDirPath "$spm" \
      -disableAutomaticPackageResolution \
      -onlyUsePackageVersionsFromResolvedFile \
      -skipMacroValidation \
      -skipPackagePluginValidation \
      -IDEPackageSupportDisableManifestSandbox=YES \
      -IDEPackageSupportDisablePluginExecutionSandbox=YES \
      OTHER_SWIFT_FLAGS='$(inherited) -Xfrontend -disable-sandbox' \
      -jobs 4 \
      build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    bundle="$PWD/.build/XcodeBundle/Build/Products/Release/VPhone.bundle"
    test -d "$bundle"

    mkdir -p "$out/Applications" "$out/bin"
    cp -a "$bundle" "$out/Applications/VPhone.bundle"

    makeWrapper "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-cli" \
      "$out/bin/vphone-cli"
    makeWrapper "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-vm" \
      "$out/bin/vphone-vm"
    makeWrapper "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-escalator" \
      "$out/bin/vphone-escalator"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-cli"
    test -x "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-vm"
    test -x "$out/Applications/VPhone.bundle/Contents/MacOS/vphone-escalator"
    "$out/bin/vphone-cli" --help >/dev/null
    /usr/bin/codesign --verify --strict "$out/Applications/VPhone.bundle"

    runHook postInstallCheck
  '';

  passthru = {
    inherit spmDeps;

    updateScript = writeShellApplication {
      name = "update-vphone-cli";
      runtimeInputs = [
        python3
        git
        cacert
        nix
      ];
      text = ''
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "Run a virtual iPhone on Apple Silicon";
    homepage = "https://github.com/Lakr233/vphone-cli";
    changelog = "https://github.com/Lakr233/vphone-cli/commits/main";
    license = lib.licenses.mit;
    mainProgram = "vphone-cli";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
