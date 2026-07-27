{ secretsDir, ... }: {

  imports = [
    ../common/home.nix

    ../../programs/ssh.nix
  ];

}
