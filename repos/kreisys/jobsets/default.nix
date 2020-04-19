{ nixpkgs ? <nixpkgs>
, declInput
}:

let
  pkgs = import nixpkgs {};

  mkJobset = branch: channel: supportedSystems: {
    "${branch}-${channel}" = {
      enabled = true;
      hidden = false;
      description = "Build ${branch} against ${channel}";
      nixexprinput = "src";
      nixexprpath = "release.nix";
      checkinterval = 30;
      schedulingshares = 100;
      emailoverride = "shaybergmann@gmail.com";
      enableemail = true;
      keepnr = 2;
      type = 0;
      inputs = {
        src = {
          type = "git";
          value = "https://github.com/kreisys/nur-packages.git ${branch}";
          emailresponsible = true;
        };

        nixpkgs = {
          type = "git";
          value = "https://github.com/NixOS/nixpkgs-channels.git ${channel}";
          emailresponsible = false;
        };

        supportedSystems = {
          type = "nix";
          value = supportedSystems;
          emailresponsible = false;
        };
      };
    };
  };

  jobsets = builtins.foldl' (jobsets: jobset: jobsets // jobset) {} [
    (mkJobset "master" "nixpkgs-unstable"     ''[ "x86_64-linux" "x86_64-darwin" ]'')
    (mkJobset "master" "nixos-unstable"       ''[ "x86_64-linux" ]'')
  ];

  jobsetsJSON = builtins.toJSON jobsets;

in {
  jobsets = pkgs.writeText "spec.json" jobsetsJSON;
}
