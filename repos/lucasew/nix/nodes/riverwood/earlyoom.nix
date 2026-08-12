{ config, lib, pkgs, ... }:

{
  # Configuração do earlyoom para riverwood
  # SIGTERM quando memória livre atinge 10% (90% de uso)
  # SIGKILL quando memória livre atinge 5% (95% de uso)
  services.earlyoom = {
    enable = true;

    # Threshold para enviar SIGTERM (10% de memória livre = 90% de uso)
    freeMemThreshold = 10;

    # Threshold para enviar SIGKILL (5% de memória livre = 95% de uso)
    freeMemKillThreshold = 5;
  };
}
