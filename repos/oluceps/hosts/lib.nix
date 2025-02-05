inputs:
let
  data = {
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
    hosts = import ./hosts.nix;
  };

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
{
  inherit data genModules;

  genOverlays = map (i: inputs.${i}.overlays.default or inputs.${i}.overlays.${i});

  hostOverlays =
    { inputs', inputs }:
    (import ../overlays.nix { inherit inputs' inputs; }) ++ [ inputs.self.overlays.default ];

  iage = type: import ../age { inherit type; };

  conn = import ../lib/conn.nix;

  sharedModules =
    [ inputs.self.nixosModules.repack ]
    ++ (genModules [
      "vaultix"
      "lanzaboote"
      "catppuccin"
      # "lix-module"
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
