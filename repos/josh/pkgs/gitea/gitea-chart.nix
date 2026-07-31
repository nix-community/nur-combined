{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://dl.gitea.com/charts/";
  chart = "gitea";
  version = "12.7.0";
  hash = "sha256-DoYl6QV7lw5v8JgnktKIdg+Q2muFsVlWoCErroEIw5k=";

  meta = {
    description = "Helm chart for Gitea, a self-hosted Git service";
    homepage = "https://gitea.com/gitea/helm-gitea";
    license = lib.licenses.mit;
  };
}
