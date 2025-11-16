inputs:
let

  genModules = map (
    let
      m = i: inputs.${i}.nixosModules;
    in
    i: (m i).default or (m i).${i}
  );

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [ inputs.nuenv.overlays.default ];
  };
in
rec {
  inherit genModules;

  data = rec {
    keys = {
      hashedPasswd = "$y$j9T$dQkjYyrZxZn1GnoZLRRLE1$nvNuCnEvJr9235CX.VXabEUve/Bx00YB5E8Kz/ewZW0";
      ageKey = "age1jr2x2m85wtte9p0s7d833e0ug8xf3cf8a33l9kjprc9vlxmvjycq05p2qq";
      sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv3S53gBU3Hqvr5o5g+yrn1B7eiaE5Y/OIFlTwU+NEG";
      sshPubKey2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65";
      skSshPubKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1";
      skSshPubKey2 = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEPx+g4PE7PvUHVHf4LdHvcv4Lb2oEl4isyIQxRJAoApAAAADnNzaDoxNzMzODEwOTE5";
      rBuildSshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOspyYctRvUtO2UMSkQEyUmjrTtsyIyIFCfvpJYHa78r";
    };
    node =
      let
        registry = (fromTOML (builtins.readFile ../registry.toml));
        inherit (registry) prefix node;
        mask = "/128";
      in
      pkgs.lib.mapAttrs (_: v: v // { unique_addr = prefix + toString (v.id + 1) + mask; }) node;

    hosts = import ./hosts.nix {
      lib = (inputs.nixpkgs).lib // {
        inherit getAddrFromCIDR;
        data = { inherit node; };
      };
    };
    ca_cert =
      let
        pki = {
          root = ''
            -----BEGIN CERTIFICATE-----
            MIIBpTCCAUugAwIBAgIUfvuy7UCKFt2uZWaU7jbZa5H/S8cwCgYIKoZIzj0EAwIw
            LjERMA8GA1UECgwITWlsaWV1aW0xGTAXBgNVBAMMEE1pbGlldWltIFJvb3QgQ0Ew
            IBcNMjUwNzE2MDAxMTU0WhgPMjA1MjEyMDEwMDExNTRaMC4xETAPBgNVBAoMCE1p
            bGlldWltMRkwFwYDVQQDDBBNaWxpZXVpbSBSb290IENBMFkwEwYHKoZIzj0CAQYI
            KoZIzj0DAQcDQgAEsoAfEGkLVf7dEc8C5D8x3UOKO9J9PlliK1NMSa5QsPhmghX9
            PL/b0ZZfsccQG7GRXvB81Mc8OSp9y0m2PM5rnaNFMEMwHQYDVR0OBBYEFHWuexIw
            qD7YcVwXuHTPzHe02qT7MBIGA1UdEwEB/wQIMAYBAf8CAQEwDgYDVR0PAQH/BAQD
            AgEGMAoGCCqGSM49BAMCA0gAMEUCIFtRgURKZS4waPg5nI0SkWq80vNkX9Ri6yfk
            vf7FhcBxAiEAtyb3/swm3it411i/zHYR5ZDLRhYjCYyiJAVp2EdVlm4=
            -----END CERTIFICATE-----
          '';
          intermediate = ''
            -----BEGIN CERTIFICATE-----
            MIIBzjCCAXSgAwIBAgIUXSZPhMXV7RmVGTARVoZLhkzqEpEwCgYIKoZIzj0EAwIw
            LjERMA8GA1UECgwITWlsaWV1aW0xGTAXBgNVBAMMEE1pbGlldWltIFJvb3QgQ0Ew
            HhcNMjUwNzIwMDIzNTQxWhcNMjgwNzE5MDIzNTQxWjA4MREwDwYDVQQKDAhNaWxp
            ZXVpbTEjMCEGA1UEAwwaTWlsaWV1aW0gSW50ZXJtZWRpYXRlIENBIDAwWTATBgcq
            hkjOPQIBBggqhkjOPQMBBwNCAAQ5SE1hafu1/QB4pqOOuds95S3HL6A9KbrbjdRJ
            FJDpQ0Ba2ip3TxgvJ0TuZafcZd9AriQK+4KKMe45J+88jkPso2YwZDAdBgNVHQ4E
            FgQUUuBxjDVDP6APjav8QLv4xqvdRwQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNV
            HQ8BAf8EBAMCAgQwHwYDVR0jBBgwFoAUda57EjCoPthxXBe4dM/Md7TapPswCgYI
            KoZIzj0EAwIDSAAwRQIhAP/ov68sNHVd+G1mghSlLQF7AvlFkeezRXRl3A3LpXig
            AiAiMKB95uZODsDB9lIaT8nAG7MRpEWSuJxUSw44Vsz9xg==
            -----END CERTIFICATE-----
          '';
        };
        inherit (inputs.nixpkgs.lib) foldl';
      in
      foldl' (acc: name: acc // { "${name}_file" = (pkgs.writeText "${name}.crt" pki.${name}); }) pki (
        builtins.attrNames pki
      );

  };

  genOverlays = map (i: inputs.${i}.overlays.default or inputs.${i}.overlays.${i});

  hostOverlays =
    { inputs', inputs }:
    (import ../overlays.nix { inherit inputs' inputs; })
    ++ [
      inputs.self.overlays.default
      inputs.nix-topology.overlays.default
    ];

  iage = type: import ../age { inherit type; };

  conn = import ../lib/conn.nix data.node;

  targetsFromNodes = (import ../lib/nodesToTargets.nix { inherit (pkgs) lib; }) data.node;

  getAddrFromCIDR = i: builtins.elemAt (pkgs.lib.splitString "/" i) 0;

  getThisNodeFrom = config: data.node.${config.networking.hostName};

  getIntraAddrFrom = config: getAddrFromCIDR (getThisNodeFrom config).unique_addr;

  getPeerHostListFrom = config: (builtins.attrNames (conn { }).${config.networking.hostName});

  sharedModules = [
    inputs.self.nixosModules.repack
  ]
  ++ (genModules [
    "vaultix"
    "lanzaboote"
    "catppuccin"
    # "lix-module"
    "nix-topology"
    "nyx"
    "self"
  ])
  ++ (with inputs.dae.nixosModules; [
    dae
    daed
  ]);

  genFilteredDirAttrsV2 =
    dir: excludes:
    let
      inherit (inputs.nixpkgs.lib)
        genAttrs
        subtractLists
        removeSuffix
        attrNames
        filterAttrs
        ;
      inherit (builtins) readDir;
    in
    genAttrs (
      subtractLists excludes (
        map (removeSuffix ".nix") (attrNames (filterAttrs (_: v: v == "regular") (readDir dir)))
      )
    );

  genCredPath = config: key: (key + ":" + config.vaultix.secrets.${key}.path);

  capitalize =
    str:
    let
      inherit (pkgs.lib.strings) toUpper substring concatStrings;
    in
    concatStrings [
      (toUpper (substring 0 1 str))
      (substring 1 16 str)
    ];

  readToStore =
    p:
    toString (
      pkgs.writeTextFile {
        name = builtins.baseNameOf p;
        text = builtins.readFile p;
      }
    );
}
