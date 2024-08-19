{
  programs.aria2 = {
    enable = true;
    settings = {
      listen-port = 60000;
      dht-listen-port = 60000;
      seed-ratio = 4.0;
      ftp-pasv = true;
    };
  };
}
