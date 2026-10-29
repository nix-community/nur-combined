# Pure evaluation tests: no VM, builds, deployment, or private-key reads.
{ nixpkgs }:
let
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
  publicPEM = ''
    -----BEGIN CERTIFICATE-----
    U1lOVEhFVElDLUZJWFRVUkU=
    -----END CERTIFICATE-----
  '';
  certificate = builtins.toFile "realm-upstream-public-fixture.pem" publicPEM;
  bundle = builtins.toFile "realm-upstream-public-chain-fixture.pem" (publicPEM + publicPEM);
  # Deliberately unavailable: successful evaluation must not depend on this file.
  keyFile = "/run/realm-upstream-evaluation-only/missing.key";
  evaluate =
    extra:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        ../nixosModules/realm-workloads.nix
        ../nixosModules/realm-spire.nix
        ../nixosModules/service-discovery.nix
        {
          networking.hostName = "fixture";
          system.stateVersion = "26.05";
          realm = {
            enable = lib.mkDefault true;
            helperPackage = pkgs.emptyDirectory;
            serviceDiscovery = {
              enable = true;
              address = "fd00::10";
            };
            spire = {
              server.enable = lib.mkDefault true;
              httpAttestation = {
                package = pkgs.emptyDirectory;
                trustHttpTransport = true;
                server.nodes.fixture.addresses = [ "fd00::10" ];
              };
            };
          };
        }
      ]
      ++ extra;
    }).config;
  upstreamModule.realm.spire.server.upstream = {
    enable = true;
    certificate = lib.mkDefault certificate;
    keyFile = lib.mkDefault keyFile;
  };
  disabled = evaluate [ ];
  enabled = evaluate [ upstreamModule ];
  withBundle = evaluate [
    upstreamModule
    { realm.spire.server.upstream.bundle = bundle; }
  ];
  failures =
    c:
    builtins.filter (
      a: !a.assertion && lib.hasPrefix "realm.spire.server.upstream:" a.message
    ) c.assertions;
  rejected = extra: failures (evaluate ([ upstreamModule ] ++ extra)) != [ ];
  rejectsPEM =
    field: text:
    rejected [
      {
        realm.spire.server.upstream.${field} =
          builtins.toFile "realm-upstream-invalid-public-fixture.pem" text;
      }
    ];
  invalidKey =
    value:
    !(builtins.tryEval (
      builtins.deepSeq
        (evaluate [
          upstreamModule
          { realm.spire.server.upstream.keyFile = lib.mkForce value; }
        ]).realm.spire.server.upstream.keyFile
        true
    )).success;
  nonNullSettings = lib.filterAttrsRecursive (_: value: value != null);
  unchanged = c: {
    agent = nonNullSettings c.services.spire.agent.settings;
    server = builtins.removeAttrs (nonNullSettings c.services.spire.server.settings) [ "plugins" ];
    plugins = builtins.removeAttrs (nonNullSettings c.services.spire.server.settings.plugins) [
      "UpstreamAuthority"
    ];
    registrations = c.realm.spire.server.registrations;
  };
  malformedPEMs = [
    ""
    "not a PEM certificate"
    "-----BEGIN PUBLIC KEY-----\nU1lOVEhFVElD\n-----END PUBLIC KEY-----\n"
    "-----BEGIN CERTIFICATE-----\nU1lOVEhFVElD\n"
    "-----BEGIN CERTIFICATE-----\n\n-----END CERTIFICATE-----\n"
    "-----BEGIN CERTIFICATE-----\nINVALID!\n-----END CERTIFICATE-----\n"
    "-----END CERTIFICATE-----\n"
    (publicPEM + "-----END CERTIFICATE-----\n")
    ("-----BEGIN CERTIFICATE-----\n" + publicPEM)
    (publicPEM + "\nPRIVATE KEY\n")
    (publicPEM + "\n-----BEGIN PRIVATE KEY-----\nSYNTHETIC\n-----END PRIVATE KEY-----\n")
    (
      publicPEM
      + "\n-----BEGIN ENCRYPTED PRIVATE KEY-----\nSYNTHETIC\n-----END ENCRYPTED PRIVATE KEY-----\n"
    )
  ];
in
lib.runTests {
  testUpstreamDefaultsAreDisabledAndNull = {
    expr = disabled.realm.spire.server.upstream;
    expected = {
      enable = false;
      certificate = null;
      bundle = null;
      keyFile = null;
    };
  };
  testDisabledAddsNoPluginCredentialsOrRestartTriggers = {
    expr = {
      plugin = disabled.services.spire.server.settings.plugins ? UpstreamAuthority;
      credentials = disabled.systemd.services.spire-server.serviceConfig.LoadCredential or [ ];
      triggers = disabled.systemd.services.spire-server.restartTriggers;
      valid = failures disabled;
    };
    expected = {
      plugin = false;
      credentials = [ ];
      triggers = [ ];
      valid = [ ];
    };
  };
  testDisabledRealmCreatesNoSpireServer = {
    expr =
      let
        c = evaluate [
          {
            realm.enable = lib.mkForce false;
            realm.spire.server.enable = lib.mkForce false;
          }
        ];
      in
      {
        service = c.systemd.services ? spire-server;
        valid = failures c;
        upstream = c.realm.spire.server.upstream;
      };
    expected = {
      service = false;
      valid = [ ];
      upstream = {
        enable = false;
        certificate = null;
        bundle = null;
        keyFile = null;
      };
    };
  };
  testDisabledDoesNotReadPublicFiles = {
    expr =
      let
        c = evaluate [
          {
            realm.spire.server.upstream.certificate = "/realm-upstream-evaluation-only/missing-public.pem";
          }
        ];
      in
      {
        valid = failures c;
        plugin = c.services.spire.server.settings.plugins ? UpstreamAuthority;
        bundle = c.realm.spire.server.upstream.bundle;
      };
    expected = {
      valid = [ ];
      plugin = false;
      bundle = null;
    };
  };
  testCertificateDefaultsToBundleWithoutRecursion = {
    expr = {
      upstream = enabled.realm.spire.server.upstream;
      valid = failures enabled;
    };
    expected = {
      upstream = {
        enable = true;
        inherit certificate keyFile;
        bundle = certificate;
      };
      valid = [ ];
    };
  };
  testDiskPluginUsesPublicPathsAndCredentialDirectory = {
    expr = enabled.services.spire.server.settings.plugins.UpstreamAuthority.disk.plugin_data;
    expected = {
      cert_file_path = toString certificate;
      bundle_file_path = toString certificate;
      key_file_path = "$CREDENTIALS_DIRECTORY/realm-upstream.key";
    };
  };
  testSystemdLoadsRuntimeKeyAndTracksPublicPEMs = {
    expr = {
      credentials = enabled.systemd.services.spire-server.serviceConfig.LoadCredential;
      triggers = enabled.systemd.services.spire-server.restartTriggers;
      expandsEnvironment = enabled.services.spire.server.expandEnv;
      commandExpandsEnvironment = lib.hasInfix "--expandEnv" enabled.systemd.services.spire-server.serviceConfig.ExecStart;
    };
    expected = {
      credentials = [ "realm-upstream.key:${keyFile}" ];
      triggers = [
        certificate
        certificate
      ];
      expandsEnvironment = true;
      commandExpandsEnvironment = true;
    };
  };
  testExplicitMultiCertificateBundleIsSupported = {
    expr = {
      valid = failures withBundle;
      path =
        withBundle.services.spire.server.settings.plugins.UpstreamAuthority.disk.plugin_data.bundle_file_path;
      triggers = withBundle.systemd.services.spire-server.restartTriggers;
    };
    expected = {
      valid = [ ];
      path = toString bundle;
      triggers = [
        certificate
        bundle
      ];
    };
  };
  testRuntimeKeyIsNotExposedInPluginSettings = {
    expr = lib.hasInfix keyFile (builtins.toJSON enabled.services.spire.server.settings);
    expected = false;
  };
  testRuntimeKeyIsNotARequiredEvaluationInput = {
    expr = builtins.deepSeq {
      upstream = enabled.realm.spire.server.upstream;
      settings = enabled.services.spire.server.settings;
      credentials = enabled.systemd.services.spire-server.serviceConfig.LoadCredential;
      triggers = enabled.systemd.services.spire-server.restartTriggers;
      valid = failures enabled;
    } true;
    expected = true;
  };
  testAttestorsDatabaseKeysAndRegistrationAreUnchanged = {
    expr = unchanged enabled;
    expected = unchanged disabled;
  };
  testShortTTLsRemainUnchanged = {
    expr =
      map
        (c: {
          ca = c.services.spire.server.settings.server.ca_ttl;
          svid = c.services.spire.server.settings.server.default_x509_svid_ttl;
        })
        [
          disabled
          enabled
        ];
    expected = lib.replicate 2 {
      ca = "24h";
      svid = "1h";
    };
  };
  testUpstreamRequiresServer = {
    expr = rejected [ { realm.spire.server.enable = lib.mkForce false; } ];
    expected = true;
  };
  testUpstreamRequiresRealmEvenWhenConfigIsDisabled = {
    expr =
      map
        (
          serverEnabled:
          rejected [
            {
              realm.enable = lib.mkForce false;
              realm.spire.server.enable = lib.mkForce serverEnabled;
            }
          ]
        )
        [
          false
          true
        ];
    expected = [
      true
      true
    ];
  };
  testUpstreamRequiresAllThreeInputs = {
    expr =
      map
        (
          field:
          rejected [
            {
              realm.spire.server.upstream.${field} = lib.mkForce null;
            }
          ]
        )
        [
          "certificate"
          "bundle"
          "keyFile"
        ];
    expected = [
      true
      true
      true
    ];
  };
  testMissingPublicFilesAreRejected = {
    expr =
      map
        (
          field:
          rejected [
            {
              realm.spire.server.upstream.${field} = "/realm-upstream-evaluation-only/missing-public.pem";
            }
          ]
        )
        [
          "certificate"
          "bundle"
        ];
    expected = [
      true
      true
    ];
  };
  testRuntimeKeyMustBeAnAbsoluteString = {
    expr = map invalidKey [
      "relative.key"
      ""
      ./realm-spire-upstream.nix
      42
    ];
    expected = [
      true
      true
      true
      true
    ];
  };
  testCertificateMustHaveExactlyOneCertificate = {
    expr = rejectsPEM "certificate" (publicPEM + publicPEM);
    expected = true;
  };
  testMalformedOrPrivatePEMsAreRejectedInBothInputs = {
    expr = map (field: map (rejectsPEM field) malformedPEMs) [
      "certificate"
      "bundle"
    ];
    expected = lib.replicate 2 (lib.replicate (builtins.length malformedPEMs) true);
  };
  testEnvironmentExpansionCannotBeDisabled = {
    expr = rejected [ { services.spire.server.expandEnv = lib.mkForce false; } ];
    expected = true;
  };
}
