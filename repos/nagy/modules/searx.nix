{
  services.searx = {
    settings = {
      server = {
        port = 8081;
        bind_address = "127.0.0.1";
        secret_key = "thesecretkey";
      };
      search.formats = [
        "html"
        "json"
      ];
    };
  };
}
