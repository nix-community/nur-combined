{
  services.sftpgo = {
    enable = true;
    settings = {
      webdavd.bindings = [
        { address = "0.0.0.0"; port = 8533; }
      ];
      httpd.bindings = [
        { address = "127.0.0.1"; port = 3336; }
      ];
    };
  };
}
