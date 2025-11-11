{pkgs}:
with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  maintainers = pkgs.lib.maintainers // {
    inogai = {
      name = "Inogai";
      email = "me@inogai.com"; # Placeholder, adjust as needed
      github = "inogai";
      githubId = 29174058;
    };
  };
}
