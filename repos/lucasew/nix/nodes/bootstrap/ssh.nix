{ ... }:
{
  # SSH config now managed by workspaced
  # See: config/.ssh/config.tmpl and config/.ssh/authorized_keys

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  programs.mosh.enable = true;
}
