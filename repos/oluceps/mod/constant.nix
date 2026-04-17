{
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  registry = lib.fromTOML (builtins.readFile ../registry.toml);
  inherit (registry) prefix node;
  genModules = map (
    let
      m = i: inputs.${i}.nixosModules;
    in
    i: (m i).default or (m i).${i}
  );

  mask = "/128";

  node-data = lib.mapAttrs (
    _: v:
    v
    // rec {
      unique_addr_nomask = prefix + toString (v.id + 1);
      unique_addr = unique_addr_nomask + mask;
    }
  ) node;

  hosts =
    (
      { lib, ... }:
      let
        srvOnEihort = map (n: n + ".nyaw.xyz") [
          "matrix"
          "gf"
          "vault"
          "photo"
          "s3"
          "ms"
          "alist"
          "book"
          "scrutiny"
          "seaweedfs"
          "oidc"
          "memos"
          "rqbit"
          "seed"
          "alert"
          "tgs"
          "jellyfin"
          "cache"
        ];
        srvOnHastur = [ ];

        getAddrFromCIDR = i: lib.elemAt (lib.splitString "/" i) 0;

        sum = lib.mkMerge [
          (lib.foldlAttrs (
            acc: name: value:
            acc
            // {
              "${getAddrFromCIDR value.unique_addr}" = lib.singleton "${name}.nyaw.xyz";
            }
          ) { } node-data)
          {
            "fdcc::3" = srvOnEihort;
            "fdcc::1" = srvOnHastur;
            "127.0.0.1" = [ "sync.nyaw.xyz" ];
          }
        ];
      in
      {
        kaambl = sum;
        hastur = sum;
        eihort = sum;
      }
    )
      { lib = lib; };

  data = {
    options.data = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "System constants and configuration data";
    };
    config.data = {
      keys = {
        hashedPasswd = "$y$j9T$dQkjYyrZxZn1GnoZLRRLE1$nvNuCnEvJr9235CX.VXabEUve/Bx00YB5E8Kz/ewZW0";
        ageKey = "age1jr2x2m85wtte9p0s7d833e0ug8xf3cf8a33l9kjprc9vlxmvjycq05p2qq";
        sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv3S53gBU3Hqvr5o5g+yrn1B7eiaE5Y/OIFlTwU+NEG";
        sshPubKey2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65";
        skSshPubKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1";
        skSshPubKey2 = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEPx+g4PE7PvUHVHf4LdHvcv4Lb2oEl4isyIQxRJAoApAAAADnNzaDoxNzMzODEwOTE5";
        rBuildSshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOspyYctRvUtO2UMSkQEyUmjrTtsyIyIFCfvpJYHa78r";
      };
      node = node-data;
      inherit hosts;
    };
  };

  pki-data = {
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

  mkFn = pkgs: {
    genOverlays = map (i: inputs.${i}.overlays.default or inputs.${i}.overlays.${i});
    conn = import ../lib/conn.nix node-data;
    targetsFromNodes = (import ../lib/nodesToTargets.nix { inherit (pkgs) lib; }) node-data;
    macToLL = (import ../lib/macToLL.nix { inherit (pkgs) lib; });
    getAddrFromCIDR = i: builtins.elemAt (pkgs.lib.splitString "/" i) 0;
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
          name = baseNameOf p;
          text = builtins.readFile p;
        }
      );
    pki = (
      lib.foldl' (
        acc: name: acc // { "${name}_file" = (pkgs.writeText "${name}.crt" pki-data.${name}); }
      ) pki-data (builtins.attrNames pki-data)
    );
  };

  fn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      _fn = mkFn pkgs;
    in
    {
      options.fn = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = { };
        description = "Helper functions for system configuration";
      };
      config.fn = _fn // {
        getThisNode = node-data.${config.networking.hostName};
        getIntraAddr = _fn.getAddrFromCIDR (node-data.${config.networking.hostName}.unique_addr);
        getPeerHostList = (builtins.attrNames (_fn.conn { }).${config.networking.hostName});
        sharedModules = (
          genModules [
            "run0-sudo-shim"
            "catppuccin"
            "nix-topology"
            "self"
          ]
        );
        genCredPath = key: (key + ":" + config.vaultix.secrets.${key}.path);
      };
    };
in
(lib.mkMerge [
  {
    flake.modules.generic = {
      data = data;
      fn = fn;
    };
  }
  {
    flake = data;
    transposition.fn.adHoc = true;
    perSystem =
      { pkgs, ... }:
      {
        fn = mkFn pkgs;
      };
  }
])
