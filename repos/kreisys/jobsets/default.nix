{ nixpkgs ? <nixpkgs>
, declInput
}:

let
  pkgs = import nixpkgs {};

  jobsets = {
    pkgs-linux = {
      enabled = true;
      hidden = false;
      description = "Linux";
      nixexprinput = "src";
      nixexprpath = "release.nix";
      checkinterval = 30;
      schedulingshares = 100;
      emailoverride = "";
      enableemail = false;
      keepnr = 10;
      inputs = {
        src = {
          type = "git";
          value = "https://github.com/kreisys/nur-packages.git master";
          emailresponsible = false;
        };

        nixpkgs = {
          type = "git";
          value = "https://github.com/NixOS/nixpkgs-channels.git nixos-unstable";
          emailresponsible = false;
        };
      };
    };
  };

  jobsetsJSON = builtins.toJSON jobsets;

in {
  jobsets = pkgs.writeText "spec.json" jobsetsJSON;
}
