{ ... }: {
  services.k3s = {
    enable = true;
    role = "server";
    serverAddr = "https://whiterun.lucao.net:6443";
  };
}
