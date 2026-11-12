{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  bun,
  makeWrapper,
  libsecret,
  libnotify,
}:
# One package: the Bun client (bin/vpn-tui) and the Go daemon (bin/vpn-tuid).
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vpn-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "vpn-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JpNXMpAv/o2y38n0a065WXjmAd4g1AgR6XcwP34J5DU=";
  };
  sourceRoot = "source/app"; # the code imports ../../../proto

  passthru = {
    # Bun dependencies: fixed-output derivation, one hash for x86_64 and aarch64.
    nodeModules = stdenvNoCC.mkDerivation {
      pname = "vpn-tui-node-modules";
      inherit (finalAttrs) version src sourceRoot;
      nativeBuildInputs = [bun];
      dontConfigure = true;
      dontFixup = true;
      buildPhase = ''
        export HOME=$TMPDIR
        bun install --frozen-lockfile --no-progress --os=linux --cpu=x64 --cpu=arm64
      '';
      installPhase = "cp -r node_modules $out";
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-gpl9ntGRIKTTIgz14p/aBJ2sQ3DZCugwzH7ypBToYjs=";
    };

    daemon = buildGoModule {
      pname = "vpn-tuid";
      inherit (finalAttrs) version src;
      vendorHash = "sha256-3O+215G9KuNSYjFVDpDMyXrXNX3tYxFb+2zRnSz9IUw=";
      subPackages = ["daemon/cmd/vpn-tuid"];
      env.CGO_ENABLED = 0;
      env.GOTOOLCHAIN = "local";
      ldflags = ["-s" "-w" "-X main.version=${finalAttrs.version}"];
      meta = finalAttrs.meta // {mainProgram = "vpn-tuid";};
    };
  };

  nativeBuildInputs = [bun makeWrapper];
  dontConfigure = true;
  # strip/patchelf break compiled bun binaries
  dontStrip = true;
  dontPatchELF = true;

  buildPhase = ''
    export HOME=$TMPDIR
    cp -r ${finalAttrs.passthru.nodeModules} node_modules
    chmod -R u+w node_modules
    mkdir -p $out/libexec
    bun run scripts/build.ts $out/libexec/vpn-tui
  '';

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper $out/libexec/vpn-tui $out/bin/vpn-tui \
      --prefix PATH : ${lib.makeBinPath [libsecret libnotify]}
    ln -s ${finalAttrs.passthru.daemon}/bin/vpn-tuid $out/bin/vpn-tuid
  '';

  meta = with lib; {
    description = "VPN manager for pentesters (OpenVPN/WireGuard, nftables kill switch): TUI/CLI client and root daemon";
    homepage = "https://github.com/Chiloute/vpn-tui";
    license = licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux"];
    maintainers = [];
    mainProgram = "vpn-tui";
  };
})
