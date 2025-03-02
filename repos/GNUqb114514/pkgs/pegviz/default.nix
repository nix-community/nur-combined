{ lib, fetchFromGitHub, rustPlatform }: 

rustPlatform.buildRustPackage rec {
  pname = "pegviz";
  version = "9f55edb563536cf959eb1e8615d505f87982348b";
  src = fetchFromGitHub {
    owner = "fasterthanlime";
    repo = pname;
    rev = version;
    hash = "sha256-sa2KVwme31J/ExzHa3IApVXFH0kctEsSN8dG4rSwzIk=";
  };
  cargoHash = "sha256-S+faDFqxtuQX7ZH1Hg3NWHSGFtWvUp0QoU8tjrSInBw=";
  meta = {
    description = "PEG trace visualizer";
    homepage = "https://github.com/fasterthanlime/pegviz";
    license = lib.licenses.mit;
    maintainers = [ "qb114514" ];
  };
}
