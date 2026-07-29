{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://rqlite.github.io/helm-charts";
  chart = "rqlite";
  version = "2.0.0";
  hash = "sha256-000jtn3L+du3YeWIh5ifJUjK3rjfBANbFiUWOfHXsFs=";

  meta = {
    description = "The lightweight, distributed relational database built on SQLite";
    homepage = "https://rqlite.io";
    license = lib.licenses.mit;
  };
}
