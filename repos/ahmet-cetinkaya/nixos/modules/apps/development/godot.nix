{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot-mono
  ];
}
