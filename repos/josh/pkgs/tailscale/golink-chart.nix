{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/tiesmaster/golink-helm-chart/golink";
  chart = "golink";
  version = "0.8.0";
  hash = "sha256-RSZtkM/lEDVhzCSEj/6xxO8kFpsUOPQ+uw9cRC1DfaY=";

  meta = {
    description = "Tailscale's golink application";
    homepage = "https://github.com/tiesmaster/golink-helm-chart";
    license = lib.licenses.mit;
  };
}
