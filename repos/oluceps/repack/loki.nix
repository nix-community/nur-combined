# https://gist.github.com/rickhull/895b0cb38fdd537c1078a858cf15d63e
{ reIf, config, ... }:
reIf {
  services.loki = {
    enable = true;
    configFile = config.vaultix.secrets.loki.path;
    # user, group, dataDir, extraFlags, (configFile)
  };
}
