{ secretsDir, ... }: {

  imports = [
    ../common/home.nix
  ];

  programs.ssh = {
    enable = true;
		matchBlocks = {
      "*" = {
				identityFile = "/home/files/secrets/files-private";
      };
      ouranos = {
        hostname = "195.201.148.94";
        user = "root";
      };
      fusus = {
        hostname = "localhost";
        user = "server";
        port = 49388;
      };
			ocih = {
				hostname = "152.67.70.13";
				user = "ubuntu";
			};
    };
  };

}
