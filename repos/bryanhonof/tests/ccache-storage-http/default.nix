# End-to-end test for the ccache-storage-http module.
#
# Two nodes, because the point being tested is that a Nix build sandbox with no
# network access can still use a remote ccache. The storage server therefore
# lives on a *separate machine*: the client's build sandbox has no route to it,
# and the only reason compilations still reach it is the storage helper running
# outside the sandbox, whose socket is bind-mounted in on demand.
{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) lib;

  feature = "ccache-use-storage-helper";
  socketPath = "/run/ccache-storage-http/socket";
  cacheDir = "/var/cache/ccache";
  serverPort = 18080;
  stateDir = "/var/lib/ccache-remote-storage";
  requestLog = "${stateDir}/requests.log";
  storageHost = "ccache-remote-storage";
  storageUser = "ccache";
  storagePassword = "s3cret";
  netrcPath = "/etc/ccache-netrc";
  # The test driver exposes each node under a pythonised version of its name.
  storageNode = lib.replaceStrings [ "-" ] [ "_" ] storageHost;

  # A Nix build sandbox gets a private network namespace holding nothing but
  # loopback, which is exactly what puts the storage node out of reach. Read
  # from /proc so the check does not depend on any network tooling being in the
  # sandbox, and so it fails loudly if sandboxing were ever turned off.
  assertOffline = ''
    echo "### the sandbox should have no network beyond loopback"
    interfaces=$(tail -n +3 /proc/net/dev | cut -d: -f1 | tr -d ' ' | sort | tr '\n' ' ')
    if [ "$interfaces" != "lo " ]; then
      echo "expected loopback only in the sandbox, found: $interfaces" >&2
      exit 1
    fi
  '';

  compileProbe =
    { statKey }:
    pkgs.writeShellApplication {
      name = "ccache-probe-${lib.removePrefix "remote_storage_" statKey}";
      excludeShellChecks = [ "SC2154" ]; # the Nix builder sets these, not the script
      runtimeInputs = [
        pkgs.ccache
        pkgs.coreutils
        pkgs.gawk
        pkgs.gcc
      ];
      text = ''
        echo "### the helper socket should be mounted"
        test -S ${socketPath}

        echo "### the ccache directory should be mounted"
        test -d ${cacheDir}

        ${assertOffline}

        export CCACHE_DIR=${cacheDir}
        export CCACHE_REMOTE_STORAGE=crsh:${socketPath}
        # Keep the shared cache group-writable for the other nix build users.
        export CCACHE_UMASK=007
        export CCACHE_TEMPDIR="$NIX_BUILD_TOP/ccache-tmp"
        export HOME="$NIX_BUILD_TOP"

        cd "$NIX_BUILD_TOP"
        printf 'int answer(void) { return 42; }\n' > answer.c

        ccache --zero-stats
        ccache gcc -c answer.c -o answer.o
        ccache --print-stats | tee stats

        stat_of() { awk -v key="$1" -F'\t' '$1 == key { print $2 }' stats; }

        errors=$(stat_of remote_storage_error)
        if [ "''${errors:-0}" -ne 0 ]; then
          echo "ccache reported ''${errors} remote storage error(s)" >&2
          exit 1
        fi

        count=$(stat_of ${statKey})
        if [ "''${count:-0}" -lt 1 ]; then
          echo "expected ccache to report at least one ${statKey}" >&2
          exit 1
        fi

        mkdir -p "$out"
        cp answer.o "$out/"
      '';
    };

  unfeaturedProbe = pkgs.writeShellApplication {
    name = "ccache-probe-unfeatured";
    excludeShellChecks = [ "SC2154" ]; # the Nix builder sets these, not the script
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      echo "### without the system feature the sandbox should stay untouched"
      if [ -e ${socketPath} ]; then
        echo "${socketPath} was mounted into a build that never asked for it" >&2
        exit 1
      fi
      if [ -e ${cacheDir} ]; then
        echo "${cacheDir} was mounted into a build that never asked for it" >&2
        exit 1
      fi
      mkdir -p "$out"
    '';
  };

  # Expressed with `derivation` rather than `mkDerivation` so the guest needs no
  # nixpkgs at all: the builder is a store path, and its closure is the only
  # input. Both Nix and the pre-build hook read `requiredSystemFeatures` straight
  # out of the derivation environment, so a plain list works here.
  sandboxBuild =
    {
      name,
      builder,
      features,
    }:
    pkgs.writeText "${name}.nix" ''
      derivation {
        name = "${name}";
        system = "${pkgs.stdenv.hostPlatform.system}";
        # builtins.storePath so that this expression, evaluated inside the VM,
        # still carries a string context for the builder. Without one Nix does
        # not count the builder as an input and never mounts it into the
        # sandbox, and the build fails before it runs.
        builder = "''${builtins.storePath "${builder}"}/bin/${builder.meta.mainProgram}";
        requiredSystemFeatures = [ ${lib.concatMapStringsSep " " (f: ''"${f}"'') features} ];
      }
    '';

  # The cold and the warm build have to hash to the same ccache entry: same
  # source, same compiler, same working directory ($NIX_BUILD_TOP is /build in
  # both sandboxes). Only the surrounding probe script differs, and ccache does
  # not hash that.
  coldBuild = sandboxBuild {
    name = "ccache-cold";
    builder = compileProbe { statKey = "remote_storage_write"; };
    features = [ feature ];
  };

  warmBuild = sandboxBuild {
    name = "ccache-warm";
    builder = compileProbe { statKey = "remote_storage_hit"; };
    features = [ feature ];
  };

  unfeaturedBuild = sandboxBuild {
    name = "ccache-unfeatured";
    builder = unfeaturedProbe;
    features = [ ];
  };
in

pkgs.testers.runNixOSTest {
  name = "ccache-storage-http";

  # The module under test contributes to `nixpkgs.overlays`, which the testing
  # framework locks down by default.
  node.pkgsReadOnly = false;

  nodes = {
    ${storageHost} =
      { pkgs, ... }:
      {
        networking.firewall.allowedTCPPorts = [ serverPort ];
        environment.systemPackages = [ pkgs.curl ]; # for the unauthenticated probe

        systemd.services.ccache-remote-storage = {
          description = "HTTP remote storage server for ccache";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = lib.escapeShellArgs [
              (lib.getExe pkgs.python3)
              # Interpolated, not passed as a path: `escapeShellArgs` would
              # `toString` it and drop the string context, leaving the unit
              # pointing at a file that never gets copied into the VM.
              "${./storage-server.py}"
              "${stateDir}/blobs"
              requestLog
              (toString serverPort)
              storageUser
              storagePassword
            ];
            DynamicUser = true;
            StateDirectory = baseNameOf stateDir;
          };
        };
      };

    client =
      { config, pkgs, ... }:
      {
        imports = [ ../../modules/ccache-storage-http.nix ];

        virtualisation.memorySize = 2048;
        virtualisation.writableStore = true;

        nix.settings = {
          experimental-features = [ "nix-command" ]; # the pre-build hook shells out to `nix show-derivation`
          sandbox = true;
          substituters = lib.mkForce [ ];
        };

        system.extraDependencies = [
          coldBuild
          warmBuild
          unfeaturedBuild
        ];

        # The unprivileged user the test builds as, the way a normal
        # `nix-build` would.
        users.users.person.isNormalUser = true;

        programs.ccache = {
          enable = true;
          inherit cacheDir;
          # Exercises the overlay that rebuilds these against ccacheStdenv, so
          # the test also covers our extending of an extraConfig that module
          # replaces.
          packageNames = [ "hello" ];
        };

        programs.nix-required-mounts.enable = true;

        services.ccache-storage-http = {
          enable = true;
          inherit socketPath;
          systemFeature = feature;
          # By name, so the test also covers the helper resolving a host and
          # crossing a real network under the service's systemd hardening.
          url = "http://${storageHost}:${toString serverPort}";
          attributes.layout = "subdirs";
          netrcFile = netrcPath;
        };

        # A real deployment would get this from a secrets manager; what matters
        # here is that it is readable only by the helper's own user, which is
        # the constraint that actually bites.
        environment.etc."${baseNameOf netrcPath}" = {
          text = ''
            machine ${storageHost}
              login ${storageUser}
              password ${storagePassword}
          '';
          mode = "0400";
          user = config.services.ccache-storage-http.user;
        };

        # Read back at runtime rather than asserted at eval time, so a failure
        # names the wiring that broke instead of aborting the whole test.
        environment.etc."ccache-stdenv-probe.json".text = builtins.toJSON {
          helloFeatures = pkgs.hello.requiredSystemFeatures or [ ];
          wrapperSetsRemoteStorage = lib.hasInfix "CCACHE_REMOTE_STORAGE" pkgs.ccacheStdenv.cc.cc.buildCommand;
          wrapperKeepsCacheDir = lib.hasInfix "CCACHE_DIR" pkgs.ccacheStdenv.cc.cc.buildCommand;
        };
      };
  };

  testScript =
    { nodes, ... }:
    let
      helper = nodes.client.services.ccache-storage-http;
    in
    ''
      import json
      import re
      import shlex


      def build(expression):
          """Build as an unprivileged user, the way a normal `nix-build` would."""
          cmd = shlex.quote(f"nix-build --no-out-link {expression}")
          status, output = client.execute(f"su person -l -c {cmd} 2>&1")
          client.log(output)
          if status != 0:
              raise Exception(f"nix-build {expression} failed with status {status}")
          return output


      def wait_for_service(node, unit, port=None):
          """Wait for a unit, dumping its journal instead of just timing out."""
          try:
              node.wait_for_unit(unit, timeout=120)
              if port is not None:
                  node.wait_for_open_port(port, timeout=120)
          except Exception:
              node.log(node.execute(f"systemctl status --no-pager {unit}")[1])
              node.log(node.execute(f"journalctl -b --no-pager -u {unit}")[1])
              raise


      start_all()

      wait_for_service(
          ${storageNode}, "ccache-remote-storage.service", port=${toString serverPort}
      )

      # ExecStartPost only returns once the socket exists and has been opened up,
      # so an active unit means the socket is ready for builds to use.
      wait_for_service(client, "ccache-storage-http.service")

      with subtest("the storage server really does require authentication"):
          code = ${storageNode}.succeed(
              "curl -s -o /dev/null -w '%{http_code}'"
              " http://localhost:${toString serverPort}/unauthenticated-probe"
          ).strip()
          assert code == "401", f"expected the server to demand credentials, got {code}"

      with subtest("the socket is reachable by the nix build users"):
          got = client.succeed("stat -c '%04a %U %G' ${socketPath}").strip()
          want = "${helper.socketMode} ${helper.user} ${helper.group}"
          assert got == want, f"unexpected socket ownership/mode: {got} (wanted {want})"

      with subtest("the helper logs to the journal"):
          journal = client.succeed("journalctl -b --no-pager -u ccache-storage-http.service")
          assert "IPC endpoint: ${socketPath}" in journal, journal
          assert "URL: http://${storageHost}:${toString serverPort}" in journal, journal

      with subtest("ccache is pointed at the helper"):
          probe = json.loads(client.succeed("cat /etc/ccache-stdenv-probe.json"))
          assert "${feature}" in probe["helloFeatures"], probe
          assert probe["wrapperSetsRemoteStorage"], probe
          assert probe["wrapperKeepsCacheDir"], probe

      with subtest("a build requesting the feature writes through to the other node"):
          ${storageNode}.succeed("truncate -s 0 ${requestLog}")
          build("${coldBuild}")
          requests = ${storageNode}.succeed("cat ${requestLog}")
          assert re.search(
              r"PUT \S+ 201 user=${storageUser}", requests
          ), f"the helper never stored anything as an authenticated user: {requests}"

      with subtest("a build with an empty local cache is served from the other node"):
          ${storageNode}.succeed("truncate -s 0 ${requestLog}")
          client.succeed("find ${cacheDir} -mindepth 1 -delete")
          build("${warmBuild}")
          requests = ${storageNode}.succeed("cat ${requestLog}")
          assert re.search(
              r"GET \S+ 200 user=${storageUser}", requests
          ), f"nothing was read back over authenticated HTTP: {requests}"

      with subtest("a build without the feature gets no mounts"):
          build("${unfeaturedBuild}")
    '';
}
