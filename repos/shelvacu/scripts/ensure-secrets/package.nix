{ writers }: writers.writeBashBin "ensure-secrets" { } (builtins.readFile ./ensure-secrets.bash)
