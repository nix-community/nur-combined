{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://open-webui.github.io/helm-charts";
  chart = "open-webui";
  version = "15.2.1";
  hash = "sha256-P0SWrU46gojLkaAjLUlc7I0/fvLuL/IsMmE13pou6vM=";

  meta = {
    description = "Helm chart for Open WebUI, a self-hosted AI chat interface";
    homepage = "https://www.openwebui.com";
    license = lib.licenses.mit;
  };
}
