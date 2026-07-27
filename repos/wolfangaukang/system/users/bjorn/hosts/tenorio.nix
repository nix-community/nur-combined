{
  pkgs,
  ...
}:

{
  users.users.bjorn = {
    home = "/Users/bjorn";
    shell = pkgs.zsh;
  };
}
