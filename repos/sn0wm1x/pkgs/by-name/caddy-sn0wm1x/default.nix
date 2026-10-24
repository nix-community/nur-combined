{
  lib,
  caddy,
  applyPatches,
  fetchpatch2,
  callPackage,
  python3,
  nix,
  writeShellApplication,
}:
let
  versions = lib.importJSON ./versions.json;
  plugins = lib.mapAttrsToList (
    _: plugin:
    if plugin ? replacement then
      "${plugin.module}@${plugin.version}=${plugin.replacement}@${plugin.version}"
    else
      "${plugin.module}@${plugin.version}"
  ) versions.plugins;
  quicPatch = fetchpatch2 {
    name = "caddy-quic-bbrv1.patch";
    url = "https://raw.githubusercontent.com/klzgrad/forwardproxy/${versions.forwardproxyRevision}/caddy-sing-quic-bbrv1.patch";
    hash = versions.patchHash;
  };
  idleTimeoutPatch = fetchpatch2 {
    name = "caddy-read-idle-timeout.patch";
    url = "https://raw.githubusercontent.com/klzgrad/forwardproxy/${versions.forwardproxyRevision}/caddy-read-idle-timeout.patch";
    hash = versions.idleTimeoutPatchHash;
  };
  patchedCaddy = applyPatches {
    name = "caddy-${caddy.version}-quic-bbrv1-source";
    src = caddy.src;
    patches = [
      quicPatch
      idleTimeoutPatch
    ];
    patchFlags = [
      "-p1"
      "--fuzz=0"
    ];
  };
  caddyWithPlugins = caddy.withPlugins {
    inherit plugins;
    hash = versions.hash;
  };
in
caddyWithPlugins.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "caddy-sn0wm1x";
    # Define the position locally for nix-update while following nixpkgs.
    version = caddy.version;

    # withPlugins normally fetches pristine Caddy with xcaddy. Apply the patch
    # before resolving dependencies, then keep the replacement relative so the
    # vendored source is reproducible and works inside the final build sandbox.
    src = prevAttrs.src.overrideAttrs (sourceAttrs: {
      pname = "caddy-sn0wm1x-src";
      dontFixup = true;
      # The complete vendored tree is verified by this fixed-output hash.
      env = sourceAttrs.env // {
        GOSUMDB = "off";
      };

      buildPhase = ''
        runHook preBuild

        export GOCACHE=$TMPDIR/go-cache
        export GOPATH=$TMPDIR/go
        cp -r ${patchedCaddy} caddy-src
        chmod -R u+w caddy-src

        XCADDY_SKIP_BUILD=1 TMPDIR="$PWD" xcaddy build v${caddy.version} \
          --replace "github.com/caddyserver/caddy/v2=$PWD/caddy-src" \
          ${lib.concatMapStringsSep " " (plugin: "--with ${lib.escapeShellArg plugin}") plugins}

        cd buildenv*
        cp -r ../caddy-src caddy
        # xcaddy stores replacements in a Go map; insertion order is random.
        # Remove both and recreate them in a stable order before vendoring.
        go mod edit \
          -dropreplace github.com/caddyserver/caddy/v2 \
          -dropreplace github.com/caddyserver/forwardproxy@${versions.plugins.forwardproxy.version}
        go mod edit \
          -replace github.com/caddyserver/caddy/v2=./caddy \
          -replace github.com/caddyserver/forwardproxy@${versions.plugins.forwardproxy.version}=github.com/klzgrad/forwardproxy@${versions.plugins.forwardproxy.version}
        # go mod init records the compiler's patch version. Use the highest
        # dependency requirement so Go patch updates do not change this hash.
        goVersion=$(go list -m -f '{{if not .Main}}{{.GoVersion}}{{end}}' all | sort -V | tail -n1)
        go mod edit -go="$goVersion" -toolchain=none
        go mod vendor
        cd ..

        runHook postBuild
      '';
    });

    # Keep only cheap installation checks here. Network integration tests are
    # independent passthru.tests, as recommended by the Nixpkgs manual.
    installCheckPhase = ''
      runHook preInstallCheck
      $out/bin/caddy version | grep -F 'v${caddy.version}'
      $out/bin/caddy build-info > build-info.txt
      ${lib.concatMapStringsSep "\n" (
        plugin:
        "grep -F ${lib.escapeShellArg "${plugin.replacement or plugin.module}\t${plugin.version}"} build-info.txt"
      ) (builtins.attrValues versions.plugins)}
      grep -F 'github.com/sagernet/sing-quic' build-info.txt
      $out/bin/caddy help docker-proxy > /dev/null
      runHook postInstallCheck
    '';

    passthru = prevAttrs.passthru // {
      inherit
        plugins
        quicPatch
        idleTimeoutPatch
        patchedCaddy
        ;
      updateScript = lib.getExe (writeShellApplication {
        name = "update-caddy-sn0wm1x";
        runtimeInputs = [
          python3
          nix
        ];
        text = ''
          exec python3 ${./update.py} "$@"
        '';
      });
      # The inherited tests target stock Caddy, not this custom build.
      tests.integration = callPackage ./tests.nix {
        caddy-sn0wm1x = finalAttrs.finalPackage;
      };
    };

    meta = prevAttrs.meta // {
      description = "Caddy with plugins selected by SN0WM1X";
      homepage = "https://github.com/sn0wm1x/ur";
      license = with lib.licenses; [
        asl20 # caddy
        mit # caddy-docker-proxy
        gpl3Plus # sing-quic
      ];
      maintainers = with lib.maintainers; [ kwaa ];
    };
  }
)
