{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://code.forgejo.org/forgejo-helm/forgejo";
  chart = "forgejo";
  version = "17.1.5";
  hash = "sha256-VUs78c2xKozpA4m2BWy605/m0+EO2Wk2McBcZTRTYfQ=";
  helmTestValues = {
    gitea = {
      admin = {
        username = "";
        password = "";
      };
    };
  };

  meta = {
    description = "Helm chart for Forgejo, a self-hosted Git forge";
    homepage = "https://forgejo.org";
    license = lib.licenses.mit;
  };
}
