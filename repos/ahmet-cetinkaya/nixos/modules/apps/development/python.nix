{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    python3
    uv # Manages project environments without mutable global installs.
  ];
}
