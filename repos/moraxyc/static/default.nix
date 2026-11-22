let
  src = builtins.fetchTarball {
    url = "https://github.com/Moraxyc/nur-packages/archive/09645eb331e55dbb50d60810dff1d77eedba2e62.tar.gz";
    sha256 = "sha256-oIDhr9JUXwFjIfVSqzpf9bVvMSXrdgI6do0MlPuIZBw=";
  };
in
{
  cities = builtins.fromJSON (builtins.readFile "${src}/cities.json");
  countries = builtins.fromJSON (builtins.readFile "${src}/countries.json");
}
