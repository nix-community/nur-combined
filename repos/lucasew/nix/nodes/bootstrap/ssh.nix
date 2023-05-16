{...}:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };
  programs.mosh.enable = true;
}
