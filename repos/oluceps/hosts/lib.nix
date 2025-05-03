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
      hasturHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4XC7dGxwY7VUPr4t+NtWL+c7pTl8g568jdv6aRbhDZ";
      kaamblHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQ8LFIGiv5IEqra7/ky0b0UgWdTGPY1CPA9cH8rMnyf";
      yidhraHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDggWYK5xp9hsspCa71V6fY4Bxgm7pBNDnDsdgMkcXWx";
      nodensHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcsSxaMn3hbiIvoHTWyVVTUZ5UjqUAmGlAwdiFmX/ey";
      azasosHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJOhSRZCY7nGhwhW6VaYGsT2dqRn5pA9Ic20bQVn4GJ";
      abhothHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5GIXqK0XUjtZip+GVlWno+Dibf43f9Zpm7ydZAWKh0";
      colourHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuN2Twf8uZqM56i0CO9AZJZIZ8c8s2ytq7RzOMaGH4H";
      eihortHostPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImlt3ABsoFfuPwiPR2vyO8sDAFEQtu3BKPqrCBdcsch";
      ageKey = "age1jr2x2m85wtte9p0s7d833e0ug8xf3cf8a33l9kjprc9vlxmvjycq05p2qq";
      sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEv3S53gBU3Hqvr5o5g+yrn1B7eiaE5Y/OIFlTwU+NEG";
      skSshPubKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1";
      skSshPubKey2 = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEPx+g4PE7PvUHVHf4LdHvcv4Lb2oEl4isyIQxRJAoApAAAADnNzaDoxNzMzODEwOTE5";
    };
    inherit (fromTOML (builtins.readFile ../registry.toml)) node;
    hosts = import ./hosts.nix {
      lib = (inputs.nixpkgs).lib // {
        inherit getAddrFromCIDR;
        data = { inherit node; };
      };
    };
    ca = {
      root = (
        pkgs.writeText "root.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIBZTCCARegAwIBAgIUK5cIP43nYTxkSom4car51xB2fyUwBQYDK2VwMC4xETAP
          BgNVBAoMCE1pbGlldWltMRkwFwYDVQQDDBBNaWxpZXVpbSBSb290IENBMCAXDTI1
          MDEyNjA3MzMxN1oYDzIxMjUwMTAyMDczMzE3WjAuMREwDwYDVQQKDAhNaWxpZXVp
          bTEZMBcGA1UEAwwQTWlsaWV1aW0gUm9vdCBDQTAqMAUGAytlcAMhAPeokscNudjM
          ghOCxZMw0lnzVWN73e4XZQObR6Z+jW/Co0UwQzAdBgNVHQ4EFgQU2FgDKiVfEizN
          YB6Uo8v+JKVo4VUwEgYDVR0TAQH/BAgwBgEB/wIBATAOBgNVHQ8BAf8EBAMCAQYw
          BQYDK2VwA0EAek7DrIzml/QbQ0pvtKXtIguAu1LkS7dJEH11ywG60ZcNsSaASp4t
          JnKJ63hPDuCvx1YlB6enilL3BMAs2CX2Dg==
          -----END CERTIFICATE-----
        ''
      );
      intermediate = (
        pkgs.writeText "intermediate.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIBvTCCAW+gAwIBAgIUAf5RM0UXJbedoKBU9/Y0EVmqSbkwBQYDK2VwMC4xETAP
          BgNVBAoMCE1pbGlldWltMRkwFwYDVQQDDBBNaWxpZXVpbSBSb290IENBMB4XDTI1
          MDIwMTE0MjEwMloXDTM1MDEzMDE0MjEwMlowODERMA8GA1UECgwITWlsaWV1aW0x
          IzAhBgNVBAMMGk1pbGlldWltIEludGVybWVkaWF0ZSBDQSAwMFkwEwYHKoZIzj0C
          AQYIKoZIzj0DAQcDQgAEOUhNYWn7tf0AeKajjrnbPeUtxy+gPSm6243USRSQ6UNA
          Wtoqd08YLydE7mWn3GXfQK4kCvuCijHuOSfvPI5D7KNmMGQwHQYDVR0OBBYEFFLg
          cYw1Qz+gD42r/EC7+Mar3UcEMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/
          BAQDAgIEMB8GA1UdIwQYMBaAFNhYAyolXxIszWAelKPL/iSlaOFVMAUGAytlcANB
          AGdqS2Qdxc74lngRWUTm9vzRwvVlIrw90Uas6I25XRlcxfwSp5h+CAizDqtoxEIK
          4OfM5E+YRurQ9FX7BuVLYwU=
          -----END CERTIFICATE-----
        ''
      );
    };
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

  getAddrFromCIDR = i: builtins.elemAt (pkgs.lib.splitString "/" i) 0;

  getThisNodeFrom = config: data.node.${config.networking.hostName};

  getIntraAddrFrom = config: getAddrFromCIDR (getThisNodeFrom config).unique_addr;

  getPeerHostListFrom = config: (builtins.attrNames (conn { }).${config.networking.hostName});

  sharedModules =
    [ inputs.self.nixosModules.repack ]
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
