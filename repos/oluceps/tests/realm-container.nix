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
    (import ../mod/telegram-search.nix).flake.modules.nixos.telegram-search
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
    testTelegramSearchRouteFileStable = {
      expr = profileFileStable "telegram-search";
      expected = true;
    };
    testProfileIngressTargetsPreserved = {
      expr = [
        profiles.realm.workloads.misskey.ingress.http.target
        profiles.realm.workloads.redis-misskey.ingress.redis.target
        profiles.realm.workloads.telegram-search.ingress.http.target
      ];
      expected = [
        "unix:/run/realm-misskey/backend/http.sock"
        "unix:/run/redis-misskey/redis.sock"
        "unix:/run/realm-telegram-search/backend/http.sock"
      ];
    };
    testProfileIngressIdentitiesPreserved = {
      expr = [
        profiles.realm.workloads.misskey.ingress.http.allowedIDs
        profiles.realm.workloads.redis-misskey.ingress.redis.allowedIDs
        profiles.realm.workloads.telegram-search.ingress.http.allowedIDs
      ];
      expected = [
        profiles.realm.caddy.allowedIDs.misskey
        [ "spiffe://nyaw.xyz/service/misskey" ]
        [ "spiffe://nyaw.xyz/service/caddy" ]
      ];
    };
    testTelegramSearchLegacyS3IdentityPreserved = {
      expr = profiles.realm.workloads.telegram-search.egress.s3.verifyID;
      expected = "spiffe://nyaw.xyz/service/caddy";
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
              "postgresql-telegram-search"
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
                  postgresql-telegram-search = "postgresql";
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
    vaultix.secrets.tg-search.path = toString (
      pkgs.writeText "dummy-search.env" "DATABASE_URL=postgresql://unused:dummy@unreachable/unused\n"
    );
    virtualisation.podman.enable = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.telegram-search-app = {
        image = lib.mkForce "realm-container-fixture:test";
        imageFile = image;
        cmd = lib.mkForce [
          "launch"
          "${pkgs.nodejs}/bin/node"
          "${backend}"
        ];
      };
      containers.misskey = {
        image = lib.mkForce "realm-container-fixture:test";
        imageFile = image;
      };
    };
    realm.workloads.telegram-search.egress.postgresql.socket =
      "/run/realm-telegram-search/custom-egress/postgresql.sock";
    systemd.tmpfiles.rules = [
      "d /run/realm-telegram-search/custom-egress 0750 root telegram-search -"
    ];
    systemd.services.realm-egress-telegram-search-postgresql = {
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
    machine.wait_for_unit("podman-telegram-search-app.service", timeout=180)
    with subtest("Telegram Search uses rootless keep-id and publishes a Unix socket"):
        machine.wait_until_succeeds("curl -sf --unix-socket /run/realm-telegram-search/backend/http.sock http://localhost/ | grep -x 0:0:mesh", timeout=30)
        machine.succeed("runuser -u telegram-search -- podman inspect telegram-search-app --format '{{.HostConfig.NetworkMode}}' | grep -x none")
        actual = machine.succeed("runuser -u telegram-search -- podman exec telegram-search-app node -p process.env.DATABASE_URL").strip()
        assert actual == "postgresql://telegram_search@127.0.0.1:15432/telegram_search?sslmode=disable", actual
        machine.fail("runuser -u nobody -- curl -sf --max-time 2 --unix-socket /run/realm-telegram-search/backend/http.sock http://localhost/")
        machine.fail("curl -sf --max-time 2 http://127.0.0.1:3336/")
    with subtest("custom egress sockets use an extra read-only bind mount"):
        machine.succeed("runuser -u telegram-search -- podman inspect telegram-search-app --format '{{json .Mounts}}' | ${pkgs.python3}/bin/python3 -c 'import json,sys; mounts=json.load(sys.stdin); assert any(m[\"Source\"] == \"/run/realm-telegram-search/custom-egress\" and m[\"Destination\"] == \"/realm/egress-postgresql\" and not m[\"RW\"] for m in mounts)' ")
    with subtest("custom socket replacement remains visible through the directory mount"):
        machine.succeed("systemctl stop realm-egress-telegram-search-postgresql.service realm-egress-telegram-search-postgresql.socket")
        machine.succeed("systemctl start realm-egress-telegram-search-postgresql.socket")
        machine.wait_until_succeeds("curl -sf --unix-socket /run/realm-telegram-search/backend/http.sock http://localhost/ | grep -x 0:0:mesh", timeout=30)
    with subtest("the SOCKS adapter is bridged to the container through a Unix socket"):
        # The bridge service is socket-activated, so this also proves that
        # realm-helper receives the listening descriptor from systemd.
        machine.succeed(
            "runuser -u telegram-search -- ${pkgs.python3}/bin/python3 -c 'import socket; s=socket.socket(socket.AF_UNIX); s.connect(\"/run/realm/telegram-search/egress/socks.sock\"); s.sendall(b\"\\x05\\x01\\x00\"); assert s.recv(2) == b\"\\x05\\x00\"'"
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
