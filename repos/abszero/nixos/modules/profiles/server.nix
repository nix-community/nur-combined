# Headless server
{
  imports = [ ./base.nix ];

  # UTC is the default but we explicitly set it to disallow imperative changing.
  time.timeZone = "UTC";

  fonts.fontconfig.enable = false;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    # Obfuscate the port. However, for a proxy server, according to
    # https://geneva.cs.umd.edu/posts/fully-encrypted-traffic/en/, this won't
    # make it less detectable by the GFW.
    ports = [ 1337 ];
  };

  environment.noXlibs = true;
}
