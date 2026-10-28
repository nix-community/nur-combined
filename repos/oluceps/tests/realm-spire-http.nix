{ nixpkgs }:
let
  # Keep this evaluation test free of builds. The files still use store paths.
  pkgs = import nixpkgs {
    system = "x86_64-linux";
    overlays = [
      (_: prev: {
        writeText =
          name: text:
          if
            builtins.elem name [
              "realm-node-attest-agent.json"
              "realm-node-attest-server.json"
              "realm-spire-http-trust-bundle.pem"
              "realm-spire-registrations.json"
            ]
          then
            builtins.toFile name text
          else
            prev.writeText name text;
      })
    ];
  };
  inherit (pkgs) lib;
  package = pkgs.emptyDirectory;
  publicBundle = ''
    -----BEGIN CERTIFICATE-----
    U1lOVEhFVElDLUZJWFRVUkU=
    -----END CERTIFICATE-----
  '';
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = lib.mkDefault "fixture";
          system.stateVersion = "26.05";
          realm = {
            enable = lib.mkDefault true;
            serviceDiscovery = {
              enable = true;
              address = "fd00::10";
            };
            spire.httpAttestation.package = package;
          };
        }
      ]
      ++ extra;
    }).config;
  httpAgent = {
    realm.spire.httpAttestation = {
      trustHttpTransport = true;
      trustBundle.text = publicBundle;
    };
  };
  httpServer = {
    realm.spire = {
      server.enable = true;
      httpAttestation = {
        server = {
          nodes.fixture.addresses = [
            "192.0.2.10"
            "fdcc::10"
          ];
        };
        trustHttpTransport = true;
      };
    };
  };
  defaults = evaluate [ ];
  trustedDefaults = evaluate [ { realm.spire.httpAttestation.trustHttpTransport = true; } ];
  agent = evaluate [ httpAgent ];
  pathBundle = evaluate [
    httpAgent
    {
      realm.spire.httpAttestation.trustBundle = {
        text = lib.mkForce null;
        path = builtins.toFile "synthetic-public-bundle.pem" publicBundle;
      };
    }
  ];
  runtimeBundle = evaluate [
    {
      realm.spire.httpAttestation = {
        trustHttpTransport = true;
        agent.trustBundlePath = "/run/bootstrap.pem";
      };
    }
  ];
  server = evaluate [ httpServer ];
  agentPlugin = agent.services.spire.agent.settings.plugins.NodeAttestor.http_fqdn;
  serverPlugin = server.services.spire.server.settings.plugins.NodeAttestor.http_fqdn;
  nonNullSettings = lib.filterAttrsRecursive (_: value: value != null);
  agentSettings = nonNullSettings agent.services.spire.agent.settings;
  serverSettings = nonNullSettings server.services.spire.server.settings;
  failures =
    c:
    builtins.filter (
      a: !a.assertion && lib.hasPrefix "realm.spire.httpAttestation:" a.message
    ) c.assertions;
  rejected = extra: failures (evaluate extra) != [ ];
  invalidNodes =
    nodes:
    !(builtins.tryEval (
      builtins.deepSeq
        (evaluate [
          httpServer
          {
            realm.spire.httpAttestation.server.nodes = lib.mkForce nodes;
          }
        ]).realm.spire.httpAttestation.server.nodes
        true
    )).success;
  helper = evaluate [
    {
      realm.enable = lib.mkForce false;
      realm.spire.httpAttestation.responder.enable = true;
    }
  ];
  helperService = helper.systemd.services.realm-node-attest-responder;
  bound = evaluate [
    {
      realm.enable = lib.mkForce false;
      realm.spire.httpAttestation = {
        controlSocket = "/run/attest-fixture/publish.sock";
        responder = {
          enable = true;
          ipv4Address = "192.0.2.10";
          ipv6Address = null;
          openFirewall = true;
        };
      };
    }
  ];
  # Exercise automatic HTTP policy and registration collection for all Realm hosts.
  clusterModule =
    (import ../mod/realm.nix {
      self = {
        modules.nixos = {
          alloy-realm = { };
          ncps-client = { };
          realm-internet = { };
        };
        nixosConfigurations = lib.genAttrs [ "fixture" "optout" ] (host: {
          config.realm = {
            enable = true;
            localIdentities = { };
            spire.registrations.worker = {
              spiffeID = "spiffe://nyaw.xyz/service/${host}";
              selectors = [ "unix:user:fixture" ];
            };
          };
        });
      };
    }).flake.modules.nixos.realm;
  cluster = evaluate [
    clusterModule
    (
      { ... }:
      {
        options = {
          data = lib.mkOption {
            type = lib.types.raw;
            default.node = {
              eihort.unique_addr_nomask = "fdcc::10";
              fixture.unique_addr_nomask = "fdcc::11";
              optout.unique_addr_nomask = "fdcc::12";
            };
          };
          realm.observability.enable = lib.mkEnableOption "fixture observation";
        };
        config.networking.hostName = "eihort";
      }
    )
  ];
  manifest = builtins.fromJSON (
    builtins.readFile (builtins.head cluster.systemd.services.realm-spire-register.restartTriggers)
  );
  expectedAlias = {
    parentID = "spiffe://nyaw.xyz/spire/agent/http_fqdn/fixture";
    spiffeID = "spiffe://nyaw.xyz/agent/fixture";
    selectors = [ "spiffe_id:spiffe://nyaw.xyz/spire/agent/http_fqdn/fixture" ];
  };
in
lib.runTests {
  testDefaultAgentUsesHttpAndRuntimeBundle = {
    expr = {
      bundle = defaults.services.spire.agent.settings.agent.trust_bundle_path;
      condition = defaults.systemd.services.spire-agent.unitConfig.ConditionPathExists;
      attestors = builtins.attrNames (nonNullSettings defaults.services.spire.agent.settings)
        .plugins.NodeAttestor;
      httpAgent = defaults.realm.spire.httpAttestation.agent.enable;
      httpServer = defaults.realm.spire.httpAttestation.server.enable;
      responder = defaults.systemd.services ? realm-node-attest-responder;
      aliases = defaults.realm.spire.server.registrations;
      rebootstrap = defaults.services.spire.agent.settings.agent.rebootstrap_mode;
      trust = defaults.realm.spire.httpAttestation.trustHttpTransport;
      runtimeBundle = defaults.realm.spire.httpAttestation.agent.trustBundlePath;
      checksBundle = defaults.systemd.services.spire-agent.serviceConfig.ExecStartPre != [ ];
    };
    expected = {
      bundle = "/etc/realm-spire/trust-bundle.pem";
      condition = "/etc/realm-spire/trust-bundle.pem";
      attestors = [ "http_fqdn" ];
      httpAgent = true;
      httpServer = false;
      responder = true;
      aliases = { };
      rebootstrap = "always";
      trust = false;
      runtimeBundle = "/etc/realm-spire/trust-bundle.pem";
      checksBundle = true;
    };
  };
  testHttpAgentRemovesJoinToken = {
    expr =
      (agentSettings.agent ? join_token_file)
      || (agentSettings.agent ? join_token)
      || (agentSettings.plugins.NodeAttestor ? join_token);
    expected = false;
  };
  testHttpServerRemovesJoinToken = {
    expr = serverSettings.plugins.NodeAttestor ? join_token;
    expected = false;
  };
  testEnrollmentWrappersAreNotInstalled = {
    expr =
      map
        (
          c:
          lib.filter (
            name:
            builtins.elem name [
              "realm-enroll"
              "realm-install-enrollment"
            ]
          ) (map lib.getName c.environment.systemPackages)
        )
        [
          defaults
          agent
          server
        ];
    expected = lib.replicate 3 [ ];
  };
  testRealmDisabledDefaultsDisableHttp = {
    expr =
      let
        c = evaluate [ { realm.enable = lib.mkForce false; } ];
      in
      {
        agent = c.realm.spire.httpAttestation.agent.enable;
        server = c.realm.spire.httpAttestation.server.enable;
        responder = c.realm.spire.httpAttestation.responder.enable;
        service = c.systemd.services ? realm-node-attest-responder;
        valid = failures c;
      };
    expected = {
      agent = false;
      server = false;
      responder = false;
      service = false;
      valid = [ ];
    };
  };
  testDefaultAgentRequiresTrustAcknowledgment = {
    expr = map (a: a.message) (failures defaults);
    expected = [
      "realm.spire.httpAttestation: set trustHttpTransport to acknowledge the trusted HTTP paths supplied by deployment."
    ];
  };
  testHttpServerEnabledBySpireServer = {
    expr = server.realm.spire.httpAttestation.server.enable;
    expected = true;
  };
  testAgentUsesExternalPluginAndJson = {
    expr = {
      command = agentPlugin.plugin_cmd;
      dataKeys = builtins.attrNames agentPlugin.plugin_data;
      json = builtins.fromJSON (builtins.readFile agentPlugin.plugin_data.config_file);
    };
    expected = {
      command = "${package}/bin/realm-node-attest-agent";
      dataKeys = [ "config_file" ];
      json = {
        fqdn = "fixture.nyaw.xyz";
        trust_domain = "nyaw.xyz";
        control_socket = "/run/realm-node-attest/control.sock";
      };
    };
  };
  testAgentBundleMatchesConditionAndRebootstraps = {
    expr = {
      bundle = builtins.readFile agent.services.spire.agent.settings.agent.trust_bundle_path;
      conditionMatches =
        agent.systemd.services.spire-agent.unitConfig.ConditionPathExists
        == agent.services.spire.agent.settings.agent.trust_bundle_path;
      mode = agent.services.spire.agent.settings.agent.rebootstrap_mode;
    };
    expected = {
      bundle = publicBundle;
      conditionMatches = true;
      mode = "always";
    };
  };
  testPublicBundlePathIsPinned = {
    expr = builtins.readFile pathBundle.services.spire.agent.settings.agent.trust_bundle_path;
    expected = publicBundle;
  };
  testPinnedSourcesReplaceDefaultRuntimePath = {
    expr =
      map
        (c: {
          runtimePath = c.realm.spire.httpAttestation.agent.trustBundlePath;
          bundle = builtins.readFile c.services.spire.agent.settings.agent.trust_bundle_path;
          valid = failures c;
        })
        [
          agent
          pathBundle
        ];
    expected = lib.replicate 2 {
      runtimePath = null;
      bundle = publicBundle;
      valid = [ ];
    };
  };
  testRuntimeBundleUsesExactPathAndCondition = {
    expr = {
      path = runtimeBundle.services.spire.agent.settings.agent.trust_bundle_path;
      condition = runtimeBundle.systemd.services.spire-agent.unitConfig.ConditionPathExists;
      mode = runtimeBundle.services.spire.agent.settings.agent.rebootstrap_mode;
      checksBundle = runtimeBundle.systemd.services.spire-agent.serviceConfig.ExecStartPre != [ ];
      failures = failures runtimeBundle;
    };
    expected = {
      path = "/run/bootstrap.pem";
      condition = "/run/bootstrap.pem";
      mode = "always";
      checksBundle = true;
      failures = [ ];
    };
  };
  testPinnedBundleTakesPrecedenceOverRuntimePath = {
    expr =
      map
        (
          source:
          let
            c = evaluate [
              {
                realm.spire.httpAttestation = {
                  trustHttpTransport = true;
                  agent.trustBundlePath = "/run/bootstrap.pem";
                  trustBundle = source;
                };
              }
            ];
          in
          {
            bundle = builtins.readFile c.services.spire.agent.settings.agent.trust_bundle_path;
            checks = c.systemd.services.spire-agent.serviceConfig.ExecStartPre or [ ];
            valid = failures c;
          }
        )
        [
          { text = publicBundle; }
          { path = builtins.toFile "fixture-public-bundle.pem" publicBundle; }
        ];
    expected = lib.replicate 2 {
      bundle = publicBundle;
      checks = [ ];
      valid = [ ];
    };
  };
  testRuntimeBundleMustBeAnAbsoluteString = {
    expr =
      map
        (
          path:
          !(builtins.tryEval (
            builtins.deepSeq
              (evaluate [
                {
                  realm.spire.httpAttestation.agent.trustBundlePath = path;
                }
              ]).realm.spire.httpAttestation.agent.trustBundlePath
              true
          )).success
        )
        [
          "bootstrap.pem"
          ""
        ];
    expected = [
      true
      true
    ];
  };
  testPinnedBundleNeedsNoRuntimeCheck = {
    expr = agent.systemd.services.spire-agent.serviceConfig.ExecStartPre or [ ];
    expected = [ ];
  };
  testSingleFamilyActivationRetainsControl = {
    expr =
      map
        (
          family:
          let
            c = evaluate [
              {
                realm.enable = lib.mkForce false;
                realm.spire.httpAttestation.responder = {
                  enable = true;
                  ipv4Address = if family == "http4" then "192.0.2.10" else null;
                  ipv6Address = if family == "http6" then "2001:db8::10" else null;
                };
              }
            ];
          in
          {
            sockets = c.systemd.services.realm-node-attest-responder.serviceConfig.Sockets;
            failures = failures c;
          }
        )
        [
          "http4"
          "http6"
        ];
    expected =
      map
        (family: {
          sockets = [
            "realm-node-attest-control.socket"
            "realm-node-attest-${family}.socket"
          ];
          failures = [ ];
        })
        [
          "http4"
          "http6"
        ];
  };
  testResponderRejectsNoHttpFamily = {
    expr = rejected [
      {
        realm.enable = lib.mkForce false;
        realm.spire.httpAttestation.responder = {
          enable = true;
          ipv4Address = null;
          ipv6Address = null;
        };
      }
    ];
    expected = true;
  };
  testAgentRequiresTrustAcknowledgment = {
    expr = rejected [
      httpAgent
      { realm.spire.httpAttestation.trustHttpTransport = lib.mkForce false; }
    ];
    expected = true;
  };
  testServerRequiresTrustAcknowledgment = {
    expr = rejected [
      httpServer
      { realm.spire.httpAttestation.trustHttpTransport = lib.mkForce false; }
    ];
    expected = true;
  };
  testAgentRequiresBundleSourceWhenRuntimePathDisabled = {
    expr = rejected [
      {
        realm.spire.httpAttestation = {
          trustHttpTransport = true;
          agent.trustBundlePath = null;
        };
      }
    ];
    expected = true;
  };
  testAgentRejectsAmbiguousBundle = {
    expr = rejected [
      httpAgent
      { realm.spire.httpAttestation.trustBundle.path = builtins.toFile "fixture.pem" publicBundle; }
    ];
    expected = true;
  };
  testAgentRejectsPrivateKeyText = {
    expr = rejected [
      httpAgent
      {
        realm.spire.httpAttestation.trustBundle.text = lib.mkForce (
          publicBundle + "\n-----BEGIN EC PRIVATE KEY-----\nSYNTHETIC\n"
        );
      }
    ];
    expected = true;
  };
  testAgentRejectsPrivateKeyPath = {
    expr = rejected [
      httpAgent
      {
        realm.spire.httpAttestation.trustBundle = {
          text = lib.mkForce null;
          path = builtins.toFile "synthetic-private-fixture.pem" (
            publicBundle + "\n-----BEGIN PRIVATE KEY-----\nSYNTHETIC\n"
          );
        };
      }
    ];
    expected = true;
  };
  testAgentRequiresRealm = {
    expr = rejected [
      httpAgent
      {
        realm.spire.httpAttestation.agent.enable = true;
        realm.enable = lib.mkForce false;
      }
    ];
    expected = true;
  };
  testServerRequiresSpireServer = {
    expr = rejected [
      httpServer
      {
        realm.spire.httpAttestation.server.enable = true;
        realm.spire.server.enable = lib.mkForce false;
      }
    ];
    expected = true;
  };
  testServerExternalPluginJson = {
    expr = {
      command = serverPlugin.plugin_cmd;
      dataKeys = builtins.attrNames serverPlugin.plugin_data;
      json = builtins.fromJSON (builtins.readFile serverPlugin.plugin_data.config_file);
      attestors = builtins.attrNames serverSettings.plugins.NodeAttestor;
    };
    expected = {
      command = "${package}/bin/realm-node-attest-server";
      dataKeys = [ "config_file" ];
      json = {
        trust_domain = "nyaw.xyz";
        nodes.fixture = {
          fqdn = "fixture.nyaw.xyz";
          addresses = [
            "192.0.2.10"
            "fdcc::10"
          ];
        };
        port = 18091;
        trust_http_transport = true;
      };
      attestors = [ "http_fqdn" ];
    };
  };
  testServerStartsWithoutAgentOrBundle = {
    expr = {
      requires = server.systemd.services.spire-server.requires;
      dependencies = builtins.filter (
        unit: lib.hasInfix "spire-agent" unit || lib.hasInfix "realm-node-attest" unit
      ) (server.systemd.services.spire-server.wants ++ server.systemd.services.spire-server.after);
      bundleCondition = server.systemd.services.spire-server.unitConfig.ConditionPathExists or null;
    };
    expected = {
      requires = [ ];
      dependencies = [ ];
      bundleCondition = null;
    };
  };
  testExplicitNodesDeclareStableAlias = {
    expr = server.realm.spire.server.registrations;
    expected.fixture.http-agent-alias = expectedAlias;
  };
  testAliasAndWorkloadsReachReconcilerManifest = {
    expr = {
      alias = manifest.fixture.http-agent-alias;
      parent = manifest.fixture.worker.parentID;
      nodes = cluster.realm.spire.httpAttestation.server.nodes;
      optoutParent = manifest.optout.worker.parentID;
      optoutAlias = manifest.optout.http-agent-alias;
    };
    expected = {
      alias = expectedAlias;
      parent = "spiffe://nyaw.xyz/agent/fixture";
      nodes = {
        fixture = {
          fqdn = "fixture.nyaw.xyz";
          addresses = [ "fdcc::11" ];
        };
        optout = {
          fqdn = "optout.nyaw.xyz";
          addresses = [ "fdcc::12" ];
        };
      };
      optoutParent = "spiffe://nyaw.xyz/agent/optout";
      optoutAlias = {
        parentID = "spiffe://nyaw.xyz/spire/agent/http_fqdn/optout";
        spiffeID = "spiffe://nyaw.xyz/agent/optout";
        selectors = [ "spiffe_id:spiffe://nyaw.xyz/spire/agent/http_fqdn/optout" ];
      };
    };
  };
  testDisabledServerCreatesNoAlias = {
    expr =
      (evaluate [
        httpServer
        { realm.spire.httpAttestation.server.enable = lib.mkForce false; }
      ]).realm.spire.server.registrations;
    expected = { };
  };
  testEmptyExplicitNodesDoNotInferClusterAliases = {
    expr =
      (evaluate [
        httpServer
        { realm.spire.httpAttestation.server.nodes = lib.mkForce { }; }
      ]).realm.spire.server.registrations;
    expected = { };
  };
  testInvalidAllowedAddressesRejected = {
    expr =
      map
        (
          address:
          invalidNodes {
            fixture = {
              addresses = [ address ];
            };
          }
        )
        [
          "node.example.invalid"
          "192.0.2.0/24"
          "999.0.0.1"
          "01.2.3.4"
          "[2001:db8::1]"
          "fe80::1%eth0"
          "1::2::3"
          "2001:db8::12345"
          ""
        ];
    expected = lib.replicate 9 true;
  };
  testLiteralIpFormsAccepted = {
    expr = invalidNodes {
      fixture.addresses = [
        "0.0.0.0"
        "255.255.255.255"
        "::"
        "::1"
        "2001:db8:0:1:2:3:4:5"
        "::ffff:192.0.2.1"
      ];
    };
    expected = false;
  };
  testEmptyAllowedAddressesRejected = {
    expr = rejected [
      httpServer
      { realm.spire.httpAttestation.server.nodes.fixture.addresses = lib.mkForce [ ]; }
    ];
    expected = true;
  };
  testHelperStartsWithoutRealmOrSpire = {
    expr = {
      valid = failures helper;
      agent = helper.services.spire.agent.enable;
      server = helper.services.spire.server.enable;
      dependencies = helperService.requires ++ helperService.wants ++ helperService.after;
      command = helperService.serviceConfig.ExecStart;
      hostNetwork = !helperService.serviceConfig.PrivateNetwork;
      dynamicUser = helperService.serviceConfig.DynamicUser;
      user = helperService.serviceConfig.User;
      capabilities = helperService.serviceConfig.CapabilityBoundingSet;
    };
    expected = {
      valid = [ ];
      agent = false;
      server = false;
      dependencies = [ ];
      command = "${package}/bin/realm-node-attest-responder --fqdn fixture.nyaw.xyz --port 18091 --control-socket /run/realm-node-attest/control.sock";
      hostNetwork = true;
      dynamicUser = true;
      user = "realm-node-attest";
      capabilities = "";
    };
  };
  testResponderResourceLimitsAndHostProtection = {
    expr = lib.getAttrs [
      "MemoryMax"
      "TasksMax"
      "CPUQuota"
      "ProtectProc"
      "ProtectKernelTunables"
      "ProtectControlGroups"
    ] helperService.serviceConfig;
    expected = {
      MemoryMax = "64M";
      TasksMax = 64;
      CPUQuota = "50%";
      ProtectProc = "invisible";
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
    };
  };
  testSocketsPassAllNamedDescriptors = {
    expr = {
      sockets = helperService.serviceConfig.Sockets;
      names = map (name: helper.systemd.sockets.${name}.socketConfig.FileDescriptorName) [
        "realm-node-attest-http4"
        "realm-node-attest-http6"
        "realm-node-attest-control"
      ];
      listeners = lib.concatMap (name: helper.systemd.sockets.${name}.listenStreams) [
        "realm-node-attest-http4"
        "realm-node-attest-http6"
        "realm-node-attest-control"
      ];
      activation = helper.systemd.sockets.realm-node-attest-control.wantedBy;
      freeBind = map (name: helper.systemd.sockets.${name}.socketConfig.FreeBind) [
        "realm-node-attest-http4"
        "realm-node-attest-http6"
      ];
      ipv6Only = helper.systemd.sockets.realm-node-attest-http6.socketConfig.BindIPv6Only;
    };
    expected = {
      sockets = [
        "realm-node-attest-control.socket"
        "realm-node-attest-http4.socket"
        "realm-node-attest-http6.socket"
      ];
      names = [
        "http4"
        "http6"
        "control"
      ];
      listeners = [
        "0.0.0.0:18091"
        "[::]:18091"
        "/run/realm-node-attest/control.sock"
      ];
      activation = [ "sockets.target" ];
      freeBind = [
        true
        true
      ];
      ipv6Only = "ipv6-only";
    };
  };
  testPublishSocketIsRootOnly = {
    expr = lib.getAttrs [
      "SocketMode"
      "SocketUser"
      "SocketGroup"
      "DirectoryMode"
    ] helper.systemd.sockets.realm-node-attest-control.socketConfig;
    expected = {
      SocketMode = "0600";
      SocketUser = "root";
      SocketGroup = "root";
      DirectoryMode = "0755";
    };
  };
  testHostBindingsAndFirewallAreIndependent = {
    expr = {
      listener = bound.systemd.sockets.realm-node-attest-http4.listenStreams;
      ipv6 = bound.systemd.sockets ? realm-node-attest-http6;
      control = bound.systemd.sockets.realm-node-attest-control.listenStreams;
      open = builtins.elem 18091 bound.networking.firewall.allowedTCPPorts;
      closedByDefault = !(builtins.elem 18091 helper.networking.firewall.allowedTCPPorts);
    };
    expected = {
      listener = [ "192.0.2.10:18091" ];
      ipv6 = false;
      control = [ "/run/attest-fixture/publish.sock" ];
      open = true;
      closedByDefault = true;
    };
  };
  testExplicitFqdnKeepsHostnameAlias = {
    expr =
      let
        c = evaluate [
          httpServer
          {
            realm.spire.httpAttestation.server.nodes.fixture.fqdn = "attest.example.invalid";
          }
        ];
        plugin = c.services.spire.server.settings.plugins.NodeAttestor.http_fqdn;
      in
      {
        fqdn = (builtins.fromJSON (builtins.readFile plugin.plugin_data.config_file)).nodes.fixture.fqdn;
        alias = c.realm.spire.server.registrations.fixture.http-agent-alias;
      };
    expected = {
      fqdn = "attest.example.invalid";
      alias = expectedAlias;
    };
  };
  testRenderedResponderUnitHasAllSocketsAndNoCapabilities = {
    expr =
      let
        text = helper.systemd.units."realm-node-attest-responder.service".text;
      in
      lib.all (line: lib.hasInfix line text) [
        "Sockets=realm-node-attest-control.socket"
        "Sockets=realm-node-attest-http4.socket"
        "Sockets=realm-node-attest-http6.socket"
        "CapabilityBoundingSet=\n"
        "PrivateNetwork=false"
        "DynamicUser=true"
        "MemoryMax=64M"
        "TasksMax=64"
        "CPUQuota=50%"
        "ProtectProc=invisible"
        "ProtectKernelTunables=true"
        "ProtectControlGroups=true"
      ]
      && !(lib.hasInfix "spire" text);
    expected = true;
  };
  testValidConfigurations = {
    expr = map failures [
      trustedDefaults
      agent
      pathBundle
      runtimeBundle
      server
      cluster
      helper
      bound
    ];
    expected = lib.replicate 8 [ ];
  };
}
