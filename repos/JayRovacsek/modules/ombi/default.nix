{
  users.groups = { download = { }; };

  services.ombi = {
    enable = true;
    port = 3579;
    group = "download";
    openFirewall = true;
  };
}
