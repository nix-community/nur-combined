{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.bjorn = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "nixers" ];
    initialHashedPassword = "$6$B2mamXY/cDsuLB8P$RepR4A9jHKPysOMj4Q3OlrSdUKuOxwpoC1.cQnA3h8opAd8eG2lzW3UZaOY3hb1TRqH4.dgpcJ4ZyAHU9fYrn/";
  };
}