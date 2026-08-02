{pkgs}: {
  mergeConfig = pkgs.writers.writePython3Bin "cliproxyapiplus-merge-config" {
    libraries = [pkgs.python3Packages.pyyaml];
    flakeIgnore = [
      "E501"
      "W503"
    ];
  } (builtins.readFile ./merge.py);
}
