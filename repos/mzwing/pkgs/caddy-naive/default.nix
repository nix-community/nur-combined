# Caddy as NaiveProxy's own release builds it: klzgrad's forwardproxy fork, on the Caddy release its tag names, with the Caddy patches from that tag.
{
  applyPatches,
  caddy,
  lib,
  source,
}: let
  version = source.caddyVersion;

  # The vendored module tree, patched Caddy included; refreshed by update-hashes.
  srcHash = "sha256-6IyRKHoQ3i5q7Bi/pMXyLJV21/UcjmYKKdQibOsdluU=";

  forwardproxy = "github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@${source.goVersion}";

  patchedCaddy = applyPatches {
    name = "caddy-${version}-naive-source";
    src = source.caddySrc;
    patches = [
      # HTTP/3 through sagernet's quic-go, sending with sing-quic's BBR.
      "${source.src}/caddy-sing-quic-bbrv1.patch"
      # Lets a narrower scope such as the timeouts handler override the read idle timeout of a request body, like a naive tunnel's.
      "${source.src}/caddy-read-idle-timeout.patch"
    ];
  };
in
  (caddy.withPlugins {
    plugins = [forwardproxy];
    hash = srcHash;
  }).overrideAttrs (prevAttrs: {
    pname = "caddy-naive";
    inherit version;

    # withPlugins vendors pristine Caddy from the module proxy; this vendors the patched tree instead.
    src = prevAttrs.src.overrideAttrs (srcAttrs: {
      # The fixed-output hash already pins the whole vendored tree.
      env = srcAttrs.env // {GOSUMDB = "off";};

      # patchShebangs would point the patched tree's setcap.sh at this platform's bash, which a fixed output must not reference.
      dontFixup = true;

      buildPhase = ''
        runHook preBuild

        export GOCACHE=$TMPDIR/go-cache
        export GOPATH=$TMPDIR/go
        cp -r ${patchedCaddy} caddy
        chmod -R u+w caddy

        XCADDY_SKIP_BUILD=1 TMPDIR="$PWD" xcaddy build v${version} \
          --replace "github.com/caddyserver/caddy/v2=$PWD/caddy" \
          --with ${forwardproxy}

        cd buildenv*
        mv ../caddy caddy
        # xcaddy records the replacement as this build directory's absolute path, which the main build never sees, and writes replacements in random map order.
        go mod edit -dropreplace github.com/caddyserver/caddy/v2 -dropreplace github.com/caddyserver/forwardproxy
        go mod edit -replace github.com/caddyserver/caddy/v2=./caddy -replace ${forwardproxy}
        # go mod init stamps the compiler's patch release; the highest requirement among the modules keeps the hash across Go updates.
        go mod edit -go="$(go list -m -f '{{if not .Main}}{{.GoVersion}}{{end}}' all | sort -V | tail -n1)" -toolchain=none
        go mod vendor
        cd ..

        runHook postBuild
      '';
    });

    passthru = prevAttrs.passthru // {dist = source.caddyDist;};

    postInstallCheck = ''
      $out/bin/caddy build-info | grep -F github.com/sagernet/sing-quic
    '';

    meta =
      prevAttrs.meta
      // {
        description = "Caddy with the forwardproxy fork that serves NaiveProxy (${source.version}), patched as its releases are";
        homepage = "https://github.com/klzgrad/forwardproxy";
        license = with lib.licenses; [
          asl20
          # sing-quic, which the BBR patch links in.
          gpl3Plus
        ];
        maintainers = [
          {
            name = "mzwing";
          }
        ];
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      };
  })
