{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://backube.github.io/helm-charts/";
  chart = "volsync";
  version = "0.16.0";
  hash = "sha256-AbYJiSSgTGWkDu32Lmc8vz/1SQnu1QSNaOC8PFCUXFw=";

  meta = {
    description = "Asynchronous data replication for Kubernetes";
    homepage = "https://volsync.readthedocs.io";
    license = lib.licenses.agpl3Only;
  };
}
