{
  imports = [ ../. ];

  sops.secrets.passwd = {
    sopsFile = ./passwd;
    format = "binary";
    neededForUsers = true;
  };
}
