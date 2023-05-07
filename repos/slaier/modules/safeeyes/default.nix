{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    safeeyes
  ];
}
