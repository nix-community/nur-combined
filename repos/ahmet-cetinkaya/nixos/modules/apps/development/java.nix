{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    jdk17
    gradle
    ktfmt
  ];
}
