# cua-driver is the MIT computer-use driver in trycua/cua (libs/cua-driver).
# Upstream's flake builds that crate from source for Linux only and publishes
# no Darwin package, so every system here uses the signed GitHub release
# archive (the same bytes the upstream installer downloads). Cua Spaces and
# the perception extension are separate products and are not in these
# archives. The per-arch tarball also carries an SDK, a Node addon, and a
# GNOME Wayland helper; only the driver CLI is installed.
#
# trycua/cua is a monorepo whose /releases/latest tag is not this driver
# (and the driver tags are prereleases, which that endpoint skips), so
# pin.json sets source.tagPrefix. Nightly tags start with "nightly-", which
# that prefix does not match.
#
# On macOS the Developer ID signature has to survive: the bundle is copied
# verbatim and fixup is skipped, because patching the Mach-O would
# invalidate it. `cua-driver mcp` relaunches exactly
# /Applications/CuaDriver.app (TCC grants are keyed to that path and the
# bundle id), so the CLI uses that copy when it exists and the store bundle
# otherwise. Copy the bundle out to /Applications; a symlink of the store
# path does not keep those grants.
{
  lib,
  stdenvNoCC,
  fetchurl,
  runtimeShell,
  autoPatchelfHook,
  makeWrapper,
  imagemagick,
  libx11,
  libxi,
  libxkbcommon,
  stdenv,
}:
let
  pin = import ../../lib/release-pin.nix {
    inherit lib fetchurl;
  } ./pin.json stdenvNoCC.hostPlatform.system;
  inherit (stdenvNoCC.hostPlatform) isDarwin isLinux;

  # `cua-driver skills install` keeps the host platform's guide and drops
  # the other two. SKILL.md still links the kept file.
  excludedSkillDocs =
    if isDarwin then
      [
        "WINDOWS.md"
        "LINUX.md"
      ]
    else
      [
        "WINDOWS.md"
        "MACOS.md"
      ];

  notices = ''
    install -Dm644 LICENSE "$out/share/doc/cua-driver/LICENSE"
    install -Dm644 THIRD_PARTY_NOTICES.md "$out/share/doc/cua-driver/THIRD_PARTY_NOTICES.md"
  '';

  # Ready to link at ~/.claude/skills/cua-driver (the directory holds SKILL.md).
  skills = stdenvNoCC.mkDerivation {
    pname = "cua-driver-skills";
    inherit (pin) version;
    src = pin.files.skills;
    sourceRoot = "cua-driver-rs-v${pin.version}-skills";

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out/"
      rm -f ${lib.concatMapStringsSep " " (name: "$out/${name}") excludedSkillDocs}
      test -f "$out/SKILL.md"
      runHook postInstall
    '';

    meta = {
      description = "Agent skill pack for cua-driver";
      homepage = "https://github.com/trycua/cua";
      license = lib.licenses.mit;
      inherit (pin) platforms;
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "cua-driver";
  inherit (pin) version src;

  sourceRoot = "cua-driver-rs-${pin.version}-${pin.arch}";

  nativeBuildInputs = lib.optionals isLinux [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = lib.optionals isLinux [
    libx11
    libxi
    libxkbcommon
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  # Rewriting the Darwin Mach-O would invalidate the Developer ID signature.
  dontFixup = isDarwin;

  installPhase =
    if isDarwin then
      ''
        runHook preInstall
        mkdir -p "$out/Applications" "$out/bin"
        cp -a CuaDriver.app "$out/Applications/"
        # PATH entry. `mcp` relaunches /Applications/CuaDriver.app when that
        # copy exists; the store bundle is the fallback for --version and
        # for a host that could not write /Applications.
        cat > "$out/bin/cua-driver" <<EOF
        #!${runtimeShell}
        installed=/Applications/CuaDriver.app/Contents/MacOS/cua-driver
        bundled=$out/Applications/CuaDriver.app/Contents/MacOS/cua-driver
        if [ -x "\$installed" ]; then
          exec "\$installed" "\$@"
        fi
        exec "\$bundled" "\$@"
        EOF
        chmod 755 "$out/bin/cua-driver"
        ${notices}
        runHook postInstall
      ''
    else
      ''
        runHook preInstall
        mkdir -p "$out/libexec/cua-driver" "$out/bin"
        # cua-cursor-theme stays beside the binary: the driver looks for
        # that compiler next to itself. ImageMagick's import is on PATH
        # because X11 window capture shells out to it. The SDK, Node addon,
        # and Wayland helper from the same archive are left unpacked.
        install -m 755 cua-driver cua-cursor-theme "$out/libexec/cua-driver/"
        makeWrapper "$out/libexec/cua-driver/cua-driver" "$out/bin/cua-driver" \
          --prefix PATH : "$out/libexec/cua-driver:${lib.makeBinPath [ imagemagick ]}"
        ${notices}
        runHook postInstall
      '';

  passthru = {
    inherit skills;
  };

  meta = {
    description = "Computer-use MCP server and CLI (official signed release)";
    homepage = "https://github.com/trycua/cua";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "cua-driver";
    inherit (pin) platforms;
  };
}
