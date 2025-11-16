{
  reIf,
  ...
}:
reIf {
  services.atuin = {
    enable = true;
    host = "fdcc::3";
    port = 8888;
    openFirewall = false;
    openRegistration = false;
    maxHistoryLength = 65536;
    database.uri = "postgresql://atuin@127.0.0.1:5432/atuin";
  };
  # systemd.services = {
  #   atuin.serviceConfig.Environment = [ "RUST_LOG=debug" ];
  # };
}
