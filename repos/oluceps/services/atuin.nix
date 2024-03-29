{ ... }: {
  enable = true;
  host = "0.0.0.0";
  port = 8888;
  openFirewall = true;
  openRegistration = false;
  maxHistoryLength = 65536;
  database.uri = "postgresql://atuin@127.0.0.1:5432/atuin";
}
