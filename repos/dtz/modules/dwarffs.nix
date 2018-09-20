{ ... }:

{
  # https://github.com/edolstra/dwarffs/blob/master/README.md
  imports = [
    (builtins.fetchGit https://github.com/edolstra/dwarffs + "/module.nix")
  ];
}
