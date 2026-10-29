{
  nixpkgs,
  evalOnly ? false,
}:
let
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-container.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          system.stateVersion = "26.05";
          realm = {
            enable = true;
            serviceDiscovery = {
              enable = true;
              address = "::1";
            };
            workloads.fixture = {
              runtime = "container";
              container = {
                name = "fixture-app";
                backendPath = "/run/fixture/backend";
                extraRoutes = [
                  {
                    port = 5432;
                    socket = "/run/postgresql/.s.PGSQL.5432";
                  }
                ];
              };
              egress = {
                database = {
                  service = "database";
                  verifyID = "spiffe://nyaw.xyz/service/database";
                  target = "[::1]:15432";
                  localPort = 15432;
                };
                direct = {
                  service = "direct";
                  verifyID = "spiffe://nyaw.xyz/service/direct";
                  target = "[::1]:15433";
                };
              };
            };
          };
          virtualisation.oci-containers.containers.fixture-app.image = "fixture:test";
        }
      ]
      ++ extra;
    }).config;
  cfg = evaluate [ ];
  volumes = c: c.virtualisation.oci-containers.containers.fixture-app.volumes;
  failures =
    c:
    map (a: a.message) (
      lib.filter (
        a: !a.assertion && lib.hasPrefix "realm.workloads.fixture.container" a.message
      ) c.assertions
    );
  duplicateInstance = evaluate [
    {
      realm.workloads.second = {
        runtime = "container";
        container = {
          name = "fixture-app";
          backendPath = "/run/second/backend";
        };
      };
    }
  ];
  custom = evaluate [
    { realm.workloads.fixture.egress.database.socket = "/run/custom/database.sock"; }
  ];
  socks = evaluate [
    {
      realm.workloads.fixture = {
        socksProxy = {
          enable = true;
          port = 11081;
        };
        egress.internet = {
          service = "internet-proxy";
          verifyID = "spiffe://nyaw.xyz/service/internet";
          target = "[::1]:15434";
          localPort = 13128;
        };
      };
    }
  ];
  disabled = evaluate [
    {
      realm.workloads.fixture = {
        enable = false;
        container.name = lib.mkForce "absent";
      };
    }
  ];
  routesVolume =
    routes: "${pkgs.writeText "fixture-routes.json" (builtins.toJSON routes)}:/realm/routes.json:ro";
  expectedRoutes = [
    {
      port = 5432;
      socket = "/run/postgresql/.s.PGSQL.5432";
    }
    {
      port = 15432;
      socket = "/realm/egress/database.sock";
    }
  ];
  profileModules = [
    (import ../mod/realm-caddy-policy.nix).flake.modules.nixos.realm
    (import ../mod/misskey.nix).flake.modules.nixos.misskey
    (
      { ... }:
      {
        options.vaultix.secrets = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                path = lib.mkOption {
                  type = lib.types.str;
                  default = toString source;
                };
                owner = lib.mkOption { type = lib.types.str; };
                mode = lib.mkOption { type = lib.types.str; };
              };
            }
          );
        };
        options.fn = lib.mkOption {
          type = lib.types.attrs;
          default.pki.root_file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };
      }
    )
  ];
  profiles = evaluate profileModules;
  profileFileStable =
    name:
    let
      w = profiles.realm.workloads.${name};
      oldRoutes =
        lib.optionals (name == "misskey") [
          {
            port = 5432;
            socket = "/run/postgresql/.s.PGSQL.5432";
          }
        ]
        ++ lib.mapAttrsToList (route: e: {
          port = e.localPort;
          socket = "/realm/egress/${route}.sock";
        }) w.egress
        ++ lib.optional w.socksProxy.enable {
          port = 11080;
          socket = "/realm/egress/socks.sock";
        };
      oldFile = pkgs.writeText "${name}-routes.json" (builtins.toJSON oldRoutes);
    in
    lib.elem "${oldFile}:/realm/routes.json:ro"
      profiles.virtualisation.oci-containers.containers.${w.container.name}.volumes;
  evalTests = lib.runTests {
    testMisskeyRouteFileStable = {
      expr = profileFileStable "misskey";
      expected = true;
    };
    testProfileIngressTargetsPreserved = {
      expr = [
        profiles.realm.workloads.misskey.ingress.http.target
        profiles.realm.workloads.redis-misskey.ingress.redis.target
      ];
      expected = [
        "unix:/run/realm-misskey/backend/http.sock"
        "unix:/run/redis-misskey/redis.sock"
      ];
    };
    testProfileIngressIdentitiesPreserved = {
      expr = [
        profiles.realm.workloads.misskey.ingress.http.allowedIDs
        profiles.realm.workloads.redis-misskey.ingress.redis.allowedIDs
      ];
      expected = [
        profiles.realm.caddy.allowedIDs.misskey
        [ "spiffe://nyaw.xyz/service/misskey" ]
      ];
    };
    testContainerInstanceCannotCombineWorkloads = {
      expr = failures duplicateInstance != [ ];
      expected = true;
    };
    testValidContainer = {
      expr = failures cfg;
      expected = [ ];
    };
    testCommonMounts = {
      expr = volumes cfg;
      expected = [
        "/run/realm/fixture/egress:/realm/egress:ro"
        "/run/fixture/backend:/realm/backend:rw"
        (routesVolume expectedRoutes)
        "${cfg.realm.helperPackage}/bin/realm-helper:/realm/helper:ro"
        "${../nixosModules/realm/container-health.cjs}:/realm/health.cjs:ro"
      ];
    };
    testNullPortExcludedAndRouteFileStable = {
      expr = lib.elem (routesVolume expectedRoutes) (volumes cfg);
      expected = true;
    };
    testCustomSocketAddsReadOnlyMount = {
      expr = lib.sort builtins.lessThan (volumes custom);
      expected = lib.sort builtins.lessThan (
        lib.filter (volume: volume != routesVolume expectedRoutes) (volumes cfg)
        ++ [
          (routesVolume [
            (builtins.head expectedRoutes)
            {
              port = 15432;
              socket = "/realm/egress-database/database.sock";
            }
          ])
          "/run/custom:/realm/egress-database:ro"
        ]
      );
    };
    testSocksUsesConfiguredPort = {
      expr = lib.elem (routesVolume (
        expectedRoutes
        ++ [
          {
            port = 13128;
            socket = "/realm/egress/internet.sock";
          }
          {
            port = 11081;
            socket = "/realm/egress/socks.sock";
          }
        ]
      )) (volumes socks);
      expected = true;
    };
    testRejectSystemdRuntime = {
      expr = builtins.length (
        failures (evaluate [ { realm.workloads.fixture.runtime = lib.mkForce "systemd"; } ])
      );
      expected = 1;
    };
    testRejectMissingInstance = {
      expr = builtins.length (
        failures (evaluate [ { realm.workloads.fixture.container.name = lib.mkForce "absent"; } ])
      );
      expected = 1;
    };
    testMissingInstanceNotCreated = {
      expr =
        builtins.hasAttr "absent"
          (evaluate [ { realm.workloads.fixture.container.name = lib.mkForce "absent"; } ])
          .virtualisation.oci-containers.containers;
      expected = false;
    };
    testInstanceNameRequired = {
      expr =
        (builtins.tryEval
          (evaluate [
            { realm.workloads.fixture.container = lib.mkForce { backendPath = "/run/fixture/backend"; }; }
          ]).realm.workloads.fixture.container.name
        ).success;
      expected = false;
    };
    testRejectDuplicateExtraAndEgressPort = {
      expr = builtins.length (
        failures (evaluate [ { realm.workloads.fixture.egress.database.localPort = lib.mkForce 5432; } ])
      );
      expected = 1;
    };
    testRejectDuplicateEgressPorts = {
      expr = builtins.length (
        failures (evaluate [ { realm.workloads.fixture.egress.direct.localPort = 15432; } ])
      );
      expected = 1;
    };
    testRejectDuplicateSocksPort = {
      expr = builtins.length (
        failures (evaluate [
          {
            realm.workloads.fixture = {
              socksProxy.enable = true;
              socksProxy.port = 15432;
            };
          }
        ])
      );
      expected = 1;
    };
    testDisabledNoMounts = {
      expr = volumes disabled;
      expected = [ ];
    };
    testDisabledNoAssertions = {
      expr = failures disabled;
      expected = [ ];
    };
    testDisabledNoUnits = {
      expr = lib.filter (
        name: lib.hasPrefix "realm-" name && !(lib.hasPrefix "realm-node-attest-" name)
      ) (builtins.attrNames disabled.systemd.services);
      expected = [ ];
    };
    testDisabledNoSockets = {
      expr = lib.filter (
        name: lib.hasPrefix "realm-" name && !(lib.hasPrefix "realm-node-attest-" name)
      ) (builtins.attrNames disabled.systemd.sockets);
      expected = [ ];
    };
    testDisabledNoRegistrations = {
      expr = disabled.realm.spire.registrations;
      expected = { };
    };
    testRealmDisabledNoMounts = {
      expr = volumes (evaluate [ { realm.enable = lib.mkForce false; } ]);
      expected = [ ];
    };
  };
  spireFixture = import ./realm-spire-fixture.nix { inherit pkgs; };
  runTest = if evalOnly then _: evalTests else pkgs.testers.runNixOSTest;
  backend = pkgs.writeText "fixture.cjs" ''
    const fs = require('node:fs');
    const http = require('node:http');
    const net = require('node:net');
    const socket = '/realm/backend/http.sock';
    if (!process.env.REALM_INGRESS_PORT) fs.rmSync(socket, { force: true });
    http.createServer((req, res) => {
      const client = net.createConnection(process.env.REALM_INGRESS_PORT ? 15432 : 5432, '127.0.0.1', () => client.write('mesh'));
      client.on('data', (data) => { res.end(process.getuid()+':'+process.getgid()+':'+data); client.end(); });
      client.on('error', () => { res.statusCode = 503; res.end('unreachable'); });
    }).listen(process.env.REALM_INGRESS_PORT ? 3333 : socket, () => {
      if (!process.env.REALM_INGRESS_PORT) fs.chmodSync(socket, 0o660);
    });
    if (process.env.REALM_INGRESS_PORT) http.createServer((req, res) => res.end('healthy')).listen(3000, '127.0.0.1');
  '';
  pnpm = pkgs.writeShellScriptBin "pnpm" "exec ${pkgs.nodejs}/bin/node ${backend}";
  image = pkgs.dockerTools.buildLayeredImage {
    name = "realm-container-fixture";
    tag = "test";
    contents = [
      pkgs.nodejs
      pkgs.coreutils
      pkgs.bash
      pnpm
    ];
    config.Env = [ "PATH=/bin" ];
  };
  source = pkgs.writeText "dummy-misskey.yml" ''
    url: https://example.invalid/
    socket: /realm/backend/http.sock
    chmodSocket: '660'
    db: { db: fixture, user: fixture, pass: dummy, host: 127.0.0.1, port: 5432 }
    redis: { host: 127.0.0.1, port: 6379 }
    meilisearch: { apiKey: dummy, host: 127.0.0.1, port: 7700 }
    proxy: http://127.0.0.1:13128
    proxyBypassHosts: [s3.nyaw.xyz]
    allowedPrivateNetworks: [127.0.0.0/8]
  '';
  echo = pkgs.writeText "echo-activation.py" ''
    import socket
    listener = socket.socket(fileno=3)
    while True:
        client, _ = listener.accept()
        with client:
            client.sendall(client.recv(65536))
  '';
in
assert evalOnly || evalTests == [ ];
runTest {
  name = "realm-rootless-container";
  nodes.machine = {
    imports = [
      ../nixosModules/realm-workloads.nix
      ../nixosModules/realm-container.nix
      spireFixture.module
      ../nixosModules/service-discovery.nix
    ]
    ++ profileModules;
    virtualisation.memorySize = 2048;
    virtualisation.diskSize = 4096;
    networking.hostName = "machine";
    environment.systemPackages = [
      pkgs.curl
      pkgs.util-linux
    ];
    realm = {
      enable = true;
      serviceDiscovery = {
        enable = true;
        address = "::1";
        catalog.fixture =
          lib.genAttrs
            [
              "fixture-database"
              "redis-misskey"
              "meilisearch"
              "https-gateway"
              "internet-proxy"
            ]
            (service: {
              address = "::1";
              port = 1;
              unit = "fixture.service";
              serverID = "spiffe://nyaw.xyz/service/${
                {
                  fixture-database = "database";
                  redis-misskey = "redis-misskey";
                  meilisearch = "meilisearch";
                  https-gateway = "caddy";
                  internet-proxy = "internet";
                }
                .${service}
              }";
            });
      };
    };
    users.groups.fixture = { };
    users.users.fixture = {
      isSystemUser = true;
      uid = 1983;
      group = "fixture";
      home = "/var/lib/fixture";
      createHome = true;
      linger = true;
      subUidRanges = [
        {
          startUid = 2147614720;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 2147614720;
          count = 65536;
        }
      ];
    };
    virtualisation.podman.enable = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.fixture-app = {
        image = "realm-container-fixture:test";
        imageFile = image;
        networks = [ "none" ];
        user = "0:0";
        podman = {
          user = "fixture";
          sdnotify = "healthy";
        };
        entrypoint = "/realm/helper";
        cmd = [
          "launch"
          "${pkgs.nodejs}/bin/node"
          "${backend}"
        ];
        extraOptions = [
          "--userns=keep-id:uid=0,gid=0"
          "--cap-drop=ALL"
          "--security-opt=no-new-privileges"
          "--health-cmd=node /realm/health.cjs"
          "--health-interval=5s"
          "--health-start-period=30s"
        ];
        environment = {
          REALM_INGRESS_PORT = "3333";
          REALM_HEALTH_PORT = "3000";
        };
      };
      containers.misskey = {
        image = lib.mkForce "realm-container-fixture:test";
        imageFile = image;
      };
    };
    realm.workloads.fixture = {
      unit = "podman-fixture-app.service";
      runtime = "container";
      container = {
        name = "fixture-app";
        backendPath = "/run/fixture/backend";
      };
      ingressGroups = [ "fixture" ];
      socksProxy.enable = true;
      ingress.http = {
        port = 13336;
        backend = {
          kind = "unix";
          path = "/run/fixture/backend/http.sock";
        };
        service = "fixture-http";
        allow.identities = [ "spiffe://nyaw.xyz/service/caddy" ];
      };
      egress = {
        database = {
          service = "fixture-database";
          localPort = 15432;
          socket = "/run/fixture/custom-egress/database.sock";
        };
        internet = {
          service = "internet-proxy";
          localPort = 13128;
        };
      };
    };
    systemd.tmpfiles.rules = [
      "d /run/fixture 0750 fixture realm-fixture -"
      "d /run/fixture/backend 0750 fixture fixture -"
      "d /run/fixture/custom-egress 0750 root fixture -"
    ];
    systemd.services.realm-egress-fixture-database = {
      requires = lib.mkForce [ ];
      after = lib.mkForce [ ];
      serviceConfig = {
        Type = lib.mkForce "simple";
        ExecStart = lib.mkForce "${pkgs.python3}/bin/python3 ${echo}";
      };
    };
    systemd.targets.postgresql = { };
    systemd.sockets.fixture-postgresql = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "/run/postgresql/.s.PGSQL.5432" ];
      socketConfig = {
        SocketUser = "misskey";
        SocketGroup = "misskey";
        SocketMode = "0660";
      };
    };
    systemd.services.fixture-postgresql.serviceConfig = {
      User = "misskey";
      ExecStart = "${pkgs.python3}/bin/python3 ${echo}";
    };
  };
  testScript = ''
    machine.start()
    ${spireFixture.startAgent}
    machine.wait_for_unit("podman-misskey.service", timeout=180)
    machine.wait_for_unit("podman-fixture-app.service", timeout=180)
    with subtest("rootless namespace-root fixture publishes a Unix socket"):
        machine.wait_until_succeeds("curl -sf --unix-socket /run/fixture/backend/http.sock http://localhost/ | grep -x 0:0:mesh", timeout=30)
        machine.succeed("runuser -u fixture -- podman inspect fixture-app --format '{{.HostConfig.NetworkMode}}' | grep -x none")
        machine.fail("runuser -u nobody -- curl -sf --max-time 2 --unix-socket /run/fixture/backend/http.sock http://localhost/")
        machine.fail("curl -sf --max-time 2 http://127.0.0.1:3333/")
    with subtest("custom egress sockets use an extra read-only bind mount"):
        machine.succeed("runuser -u fixture -- podman inspect fixture-app --format '{{json .Mounts}}' | ${pkgs.python3}/bin/python3 -c 'import json,sys; mounts=json.load(sys.stdin); assert any(m[\"Source\"] == \"/run/fixture/custom-egress\" and m[\"Destination\"] == \"/realm/egress-database\" and not m[\"RW\"] for m in mounts)' ")
    with subtest("custom socket replacement remains visible through the directory mount"):
        machine.succeed("systemctl stop realm-egress-fixture-database.service realm-egress-fixture-database.socket")
        machine.succeed("systemctl start realm-egress-fixture-database.socket")
        machine.wait_until_succeeds("curl -sf --unix-socket /run/fixture/backend/http.sock http://localhost/ | grep -x 0:0:mesh", timeout=30)
    with subtest("the SOCKS adapter is bridged to the container through a Unix socket"):
        # The bridge service is socket-activated, so this also proves that
        # realm-helper receives the listening descriptor from systemd.
        machine.succeed(
            "runuser -u fixture -- ${pkgs.python3}/bin/python3 -c 'import socket; s=socket.socket(socket.AF_UNIX); s.connect(\"/run/realm/fixture/egress/socks.sock\"); s.sendall(b\"\\x05\\x01\\x00\"); assert s.recv(2) == b\"\\x05\\x00\"'"
        )
    with subtest("container receives prepared configuration unchanged"):
        expected = machine.succeed("cat ${source}")
        actual = machine.succeed("runuser -u misskey -- podman exec misskey cat /misskey/.config/default.yml")
        assert actual == expected
    with subtest("rootless keep-id mapping and Unix egress"):
        machine.wait_until_succeeds("curl -sf --unix-socket /run/realm-misskey/backend/http.sock http://localhost/ | grep -x 1000:1000:mesh", timeout=30)
    with subtest("backend socket is not exposed to unrelated users"):
        machine.fail("runuser -u nobody -- curl -sf --max-time 2 --unix-socket /run/realm-misskey/backend/http.sock http://localhost/")
    with subtest("container has no directly connected network"):
        machine.succeed("runuser -u misskey -- podman inspect misskey --format '{{.HostConfig.NetworkMode}}' | grep -x none")
        machine.fail("curl -sf --max-time 2 http://127.0.0.1:3012/")
  '';
}
