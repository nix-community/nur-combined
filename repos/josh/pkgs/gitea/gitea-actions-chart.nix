{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://dl.gitea.com/charts/";
  chart = "actions";
  version = "0.1.2";
  sha256 = "sha256-w4m98OUGJGInipFPEB96zyGRndD/Sq4hRMukLaGFgTo=";
  helmTestValues = {
    enabled = true;
    giteaRootURL = "https://gitea.example.com/";
    existingSecret = "gitea-runner-token";
    existingSecretKey = "token";
  };
}
