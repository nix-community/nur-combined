{
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  default = final: prev: {
    linux-enable-ir-emitter = final.nur.repos.mio.linux-enable-ir-emitter;
  };
}
