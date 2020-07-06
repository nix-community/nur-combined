{ pkgs, ... }:

{
  home.packages = with pkgs; [ ledger ];
}
