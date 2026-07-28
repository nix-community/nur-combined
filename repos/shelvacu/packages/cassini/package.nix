{
  fetchFromGitHub,
  python3Packages,
  writers,
  cassini,
}:
let
  finalAttrs = cassini; # todo: when 26.05 comes around, change this to use the function style
in
python3Packages.buildPythonApplication {
  pname = "cassini";
  version = "0-unstable-2024-03-30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "vvuk";
    repo = "cassini";
    rev = "052265f2a287b40e06971cfa3d66fc83bda19f93";
    hash = "sha256-lk4Y5aGSVHBY4Lju7Q9QDknSvo8PK6YdhQkmoIhFVec=";
  };

  pyproj_toml = writers.writeTOML "${finalAttrs.pname}-pyproject.toml" finalAttrs.passthru.pyproj;

  postPatch = ''
    cp -T "$pyproj_toml" pyproject.toml
    sed -i '/^main()$/ d' cassini.py
  '';

  build-system = [ python3Packages.hatchling ];

  propagatedBuildInputs = [
    python3Packages.alive-progress
    python3Packages.scapy
  ];

  pythonImportsCheck = [ "cassini" ];

  passthru.pyproj = {
    project = {
      name = finalAttrs.pname;
      version = "0.0.0.2024.03.30";
      scripts.cassini = "cassini:main";
    };
    build-system = {
      requires = [ "hatchling" ];
      build-backend = "hatchling.build";
    };
    tool.hatch.build.targets.wheel.include = [ "*.py" ];
  };
}
