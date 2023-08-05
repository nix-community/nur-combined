# trampoline from flake.nix into the specific host definition, while doing a tiny bit of common setup

# args from flake-level `import`
{ hostName }:

# module args
{ ... }:

{
  imports = [
    ./by-name/${hostName}
    ./common
    ./modules
  ];

  networking.hostName = hostName;
}
