{...}:
{
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };
  programs.mosh.enable = true;
}
