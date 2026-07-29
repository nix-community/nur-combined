{ lib, nur }:
nur.repos.josh.fetchhelm {
  pname = "cloudnative-pg";
  url = "https://cloudnative-pg.github.io/charts";
  chart = "cloudnative-pg";
  version = "0.29.0";
  hash = "sha256-kEFuvG5CsJ/iloIbBKcrDj1Ta0ZRxJ+KJ5LODMjbY8A=";

  meta = {
    description = "CloudNativePG Operator Helm Chart";
    homepage = "https://cloudnative-pg.io";
    license = lib.licenses.asl20;
  };
}
