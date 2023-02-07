{...}: {
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "8.8.8.8" "8.8.4.4" ];
      domain-needed = true;
      bogus-priv = true;
      hostsdir = "/etc/extraHosts";
    };
  };
}
