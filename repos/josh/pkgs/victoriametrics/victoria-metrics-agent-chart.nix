{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-agent";
  version = "0.40.0";
  sha256 = "sha256-pcHmuphhKEozXSHwr4xpF+Ioa6ny8Jz72mXcWW4zhMY=";
  helmTestValues = {
    remoteWrite = [
      { url = "http://localhost:8428/api/v1/write"; }
    ];
  };
}
