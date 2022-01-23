{ pkgs }:

with pkgs.lib; recursiveUpdate pkgs.lib {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  maintainers.SomeoneSerge = {
    email = "sergei.kozlukov@aalto.fi";
    matrix = "@ss:someonex.net";
    github = "SomeoneSerge";
    githubId = 9720532;
    name = "Sergei K";
  };
}
