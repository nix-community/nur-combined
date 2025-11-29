{
  python313Packages,
  fetchPypi,
}:
with let
  overrides = self: super: {
    rich = super.rich.overridePythonAttrs (prev: rec {
      version = "13.9.4";
      src = fetchPypi {
        inherit (prev) pname;
        inherit version;
        hash = "sha256-Q5WUl4pJoJUwz/frxLXHED71e69I1eoxhPIdmivvoJg=";
      };
      doCheck = false;
    });
  };
in
python313Packages.override {
  inherit overrides;
};
buildPythonApplication rec {
  pname = "wallpaper-fetcher";
  version = "0.2.6";
  src = fetchPypi {
    pname = "wallpaper_fetcher";
    inherit version;
    hash = "sha256-UEJWB1/mAcGNfnzmu9eEeQJK2YLvUgMprqPrPTzvQJ8=";
  };
  pyproject = true;
  build-system = [ poetry-core ];
  dependencies = [
    requests
    rich
  ];
}
