{
  flake.modules.nixos.linkwarden =
    { config, ... }:
    {
      vaultix.secrets.linkwarden = {
        owner = "root";
        mode = "400";
      };
      virtualisation.oci-containers.containers.linkwarden = {
        image = "ghcr.io/linkwarden/linkwarden:latest";
        extraOptions = [
        ];
        environmentFiles = [
          config.vaultix.secrets.linkwarden.path
        ];
        environment = {
          NEXT_PUBLIC_OLLAMA_ENDPOINT_URL = "http://host.containers.internal:11434";
          OLLAMA_MODEL = "phi3:mini-4k";
        };
        ports = [
          "3004:3000"
        ];
        volumes = [
          "/var/lib/linkwarden:/data/data"
        ];
      };
    };
}
