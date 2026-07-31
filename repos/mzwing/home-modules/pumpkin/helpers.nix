{pkgs}: {
  mergeConfig = pkgs.writers.writePython3Bin "pumpkin-merge-config" {
    libraries = [pkgs.python3Packages.tomli-w];
    flakeIgnore = [
      "E501"
      "W503"
    ];
  } (builtins.readFile ./merge.py);

  manageWhitelist =
    pkgs.writers.writePython3Bin "pumpkin-manage-whitelist" {
      flakeIgnore = [
        "E501"
        "W503"
      ];
    }
    (builtins.readFile ./whitelist.py);
}
