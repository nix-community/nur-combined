{ pkgs }:
with import ../swift-builders { inherit pkgs; };
mkPackage rec {
  name = "Yams";
  version = "4.0.6";
  src = pkgs.fetchFromGitHub {
    owner = "jpsim";
    repo = "Yams";
    rev = "${version}";
    sha256 = "sha256-haysR6hdPF9MWZ0U8KIn3wC3PptvFhVijUroqEfwI6E=";
  };
  targets = [
    {
      name = "CYaml";
      type = TargetType.CLibrary;
    }
    {
      name = "Yams";
      type = TargetType.Library;
      deps = [ "CYaml" ];
    }
  ];
}
