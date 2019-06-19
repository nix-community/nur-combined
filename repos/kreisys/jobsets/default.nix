{ nixpkgs ? <nixpkgs>
, declInput
}:

let
  pkgs = import nixpkgs {};

  jobsets = {
    pkgs = {
      enabled = true;
      hidden = false;
      description = "Linux";
      nixexprinput = "src";
      nixexprpath = "release.nix";
      checkinterval = 30;
      schedulingshares = 100;
      emailoverride = "";
      enableemail = true;
      keepnr = 10;
      inputs = {
        src = {
          type = "git";
          value = "https://github.com/kreisys/nur-packages.git master";
          emailresponsible = true;
        };

        nixpkgs = {
          type = "git";
          value = "https://github.com/NixOS/nixpkgs-channels.git nixpkgs-unstable";
          emailresponsible = false;
        };

        supportedSystems = {
          type = "nix";
          value = ''
            [ "x86_64-linux" "x86_64-darwin" ]
          '';
          emailresponsible = false;
        };
      };
    };
  };

  jobsetsJSON = builtins.toJSON jobsets;

in {
  jobsets = pkgs.writeText "spec.json" jobsetsJSON;
}
