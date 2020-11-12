{pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    rclone
    rclone-browser
    restic
  ];
}
