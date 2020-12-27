{pkgs, ...}:
{
  # steam
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
  environment.systemPackages = with pkgs; [
    steam
  ];
}
