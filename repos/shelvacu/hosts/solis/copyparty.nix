{ vacuModules, ... }:
{
  imports = [ vacuModules.copyparty-solis ];
  vacu.copyparties.solis.configureFileServer = true;
}
