{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  name = "shell";
  buildInputs = with pkgs; [
    kubectl
    terraform
    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];
}
