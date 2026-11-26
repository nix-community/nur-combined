# The rexglue SDK the upstream Skate 3 recompilation builds against.
#
# The SDK pins an ImGui commit that ocornut/imgui no longer serves. Submodule
# initialization therefore needs the ImGui index entry rewritten before the
# recursive update, which needs network and makes this a fixed-output
# derivation.
#
# The checkout is stored without git metadata and with one mtime everywhere:
# git's indexes, reflogs and checkout timestamps would otherwise make the same
# clone hash differently on every run. The SDK's configure step only checks
# that the submodule .git files exist, and those hold relative gitdir paths.
{
  lib,
  stdenvNoCC,
  git,
  cacert,
  coreutils,
  findutils,
}:
let
  # The SDK submodule pin in the upstream release.
  rev = "7eb0faf7787f5e01333c228b8e3f03c32f7295ea";
  # A revision of ocornut/imgui that is still served by GitHub, used in place
  # of the SDK's unavailable cdda62349d6068e906c2e0ee340d6ec31eedbb9c.
  imguiRev = "e0a2f6dea98f76a793a6e62a2bdb7ee9b29f5add";
in
stdenvNoCC.mkDerivation {
  pname = "rexglue-skate3-sdk";
  # The pinned commit's date. This derivation has no release of its own, so
  # the version follows the repository's 0-unstable-<date> form; update.sh
  # refreshes it when the release names a different SDK commit.
  version = "0-unstable-2026-07-24";

  dontUnpack = true;
  # A fixed-output derivation must not embed Nix store paths, and the
  # checkout's shell scripts are not run by the build.
  dontPatchShebangs = true;
  nativeBuildInputs = [
    git
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
    # The SDK's old ImGui commit is unavailable, so submodule initialization
    # has to use a served revision before recursing.
    git -C sdk update-index --cacheinfo 160000,${imguiRev},thirdparty/imgui
    git -C sdk submodule update --init --recursive

    # Drop the superproject's .git directory (indexes, reflogs and checkout
    # timestamps would make the same clone hash differently on every run) but
    # keep the submodules' .git files: the SDK's configure step refuses to run
    # without them, and they only hold a relative gitdir path.
    ${findutils}/bin/find sdk -name .git -type d -prune -exec rm -rf {} +
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
  outputHash = "sha256-4eYd2Bxg3kRBbeXOEwJwSBqkxltNtzV6qE3Wd3O+bxk=";

  meta = {
    description = "rexglue SDK used by Skate 3 Recomp";
    license = lib.licenses.unfree;
  };
}
