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
      nixexprinput = "declInput";
      nixexprpath = "release.nix";
      checkinterval = 30;
      schedulingshares = 100;
      enableemail = true;
      emailoverride = "sbergmann@benbria.ca";
      keepnr = 10;
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/NixOS/nixpkgs-channels.git nixpkgs-unstable";
        emailresponsible = false;
      };
    };
  };

  jobsetsJSON = builtins.toJSON jobsets;

in {
  jobsets = pkgs.writeText "spec.json" jobsetsJSON;
}
