{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
  ];

  services.buildbot-nix = {
    master = {
      enable = true;
      authBackend = "none";
      allowUnauthenticatedControl = true; # TODO
      domain = "localhost:8010";
      enableNginx = false;
      showTrace = true;
      workersFile = pkgs.writeText "workers.json" ''
        [
          { "name": "lem", "pass": "lem-test", "cores": 16 }
        ]
      '';
      admins = [ "eownerdead" ];
      pullBased = {
        repositories = {
          flakes = {
            defaultBranch = "main";
            url = "https://codeberg.org/eownerdead/flakes";
          };
        };
        pollInterval = 60 * 60;
      };
      effects.perRepoSecretFiles = {
        "pull-based:unknown/*" = "/var/lib/buildbot-nix/secrets.json";
      };
    };
    worker = {
      enable = true;
      workerPasswordFile = pkgs.writeText "worker-password-file" "lem-test";
    };
  };
}
