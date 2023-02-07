{ pkgs, ... }: { environment.systemPackages = with pkgs; [ htop vim git ]; }
