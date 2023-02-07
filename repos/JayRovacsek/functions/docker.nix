{ containerConfig, ... }: {
  "${containerConfig.serviceName}" = {
    inherit (containerConfig) autoStart;
    inherit (containerConfig) image;
    inherit (containerConfig) ports;
    inherit (containerConfig) volumes;
    inherit (containerConfig) environment;
    inherit (containerConfig) extraOptions;
    # user = containerConfig.user;
  };
}
