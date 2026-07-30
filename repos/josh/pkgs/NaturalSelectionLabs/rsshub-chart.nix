{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://naturalselectionlabs.github.io/helm-charts";
  chart = "rsshub";
  version = "0.2.9";
  hash = "sha256-CZ5JBgeVTVS0yNYpmX/CWN6MzlQ9ylVcbaEHAmVcSCA=";

  meta = {
    description = "Helm chart for RSSHub, an extensible RSS feed generator";
    homepage = "https://github.com/NaturalSelectionLabs/helm-charts";
    license = lib.licenses.mit;
  };
}
