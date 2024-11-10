{
  sops.age.keyFile = "/persist/key.txt";
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
}
