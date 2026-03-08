{ pkgs, ... }:

{

  environment.systemPackages = [
    (pkgs.pytr.overrideAttrs (
      {
        postPatch ? "",
        ...
      }:
      {
        # src = builtins.fetchTarball "https://github.com/pytr-org/pytr/archive/1cc184bf3af5430f67ee8eadae8463f832912c0c.tar.gz";
        # version = "0.1.0";
        postPatch = postPatch + ''
          substituteInPlace pytr/main.py \
            --replace-fail 'check_version(installed_version)' ""
        '';
      }
    ))
  ];

  # https://github.com/pytr-org/pytr/issues/249
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-ecdsa-0.19.1"
  ];

}
