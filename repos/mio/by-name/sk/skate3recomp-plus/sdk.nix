# The rexglue SDK Skate 3 Recompiled+ builds against: the fork commit the
# release names, the fork's own patch, and the ImGui revision that patch pins.
#
# The upstream SDK records an ImGui commit that ocornut/imgui no longer
# serves, so its submodules can only be initialized in the order
# tools/apply_sdk_patches.py documents (patch the SDK, rewrite the ImGui index
# entry, then recurse). That needs network, hence a fixed-output derivation.
#
# The checkout is stored without git metadata and with one mtime everywhere:
# git's indexes, reflogs and checkout timestamps would otherwise make the
# same clone hash differently on every run. The game's configure-time check
# that the patch is applied is skipped for the same reason (see package.nix).
{
  lib,
  stdenvNoCC,
  git,
  cacert,
  python3,
  coreutils,
  findutils,
  gameSrc,
}:
let
  # The release names the fork commit it builds against in
  # tools/apply_sdk_patches.py; taking it from there keeps the two in step.
  patchScript = builtins.readFile "${gameSrc}/tools/apply_sdk_patches.py";
  revision = lib.removeSuffix "'" (
    lib.removePrefix "SDK_REVISION = '" (
      lib.findFirst (line: lib.hasPrefix "SDK_REVISION = '" line) "" (lib.splitString "\n" patchScript)
    )
  );
  rev =
    if revision == "" then throw "sdk.nix: no SDK_REVISION in tools/apply_sdk_patches.py" else revision;
in
stdenvNoCC.mkDerivation {
  pname = "rexglue-skate3-sdk";
  version = "unstable-2026-10-25";

  dontUnpack = true;
  # A fixed-output derivation must not embed Nix store paths, and the
  # checkout's shell scripts are not run by the build.
  dontPatchShebangs = true;
  nativeBuildInputs = [
    git
    python3
    coreutils
    findutils
  ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt
    export GIT_TERMINAL_PROMPT=0

    git clone https://github.com/mchughalex/rexglue-skate3.git sdk
    git -C sdk checkout ${rev}
    python3 ${gameSrc}/tools/apply_sdk_patches.py --sdk sdk
    git -C sdk submodule update --init --recursive

    ${findutils}/bin/find sdk -name .git -prune -exec rm -rf {} +
    ${findutils}/bin/find sdk \( -name '*.pyc' -o -name __pycache__ -o -name FETCH_HEAD -o -name ORIG_HEAD \) -prune -exec rm -rf {} +
    ${findutils}/bin/find sdk -exec ${coreutils}/bin/touch -h -d @1 {} +

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a sdk/. $out/
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-Y1HhY9xrY44faeLAMf4EkIyEnc7pTfwgplTAMa7SkWs=";

  meta = {
    description = "rexglue SDK fork patched for Skate 3 Recompiled+";
    license = lib.licenses.unfree;
  };
}
