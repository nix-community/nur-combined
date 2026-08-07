args:

{
  # keep-sorted start
  git-pages = import ./git-pages.nix args;
  maubot-exporter = import ./maubot-exporter.nix args;
  mistserver = import ./mistserver.nix args;
  timedout-registry = import ./timedout-registry.nix args;
  uptime-kuma-matrix = import ./uptime-kuma-matrix.nix args;
  venator = import ./venator.nix args;
  # keep-sorted end
}
