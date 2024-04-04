{ ... }:
{
  nix.buildMachines = [
    {
      hostName = "hpm";
      maxJobs = 8;
      speedFactor = 5;
      systems = [
        "x86_64-linux"
      ];
      supportedFeatures = [ "big-parallel" ];
    }
    {
      hostName = "acern";
      maxJobs = 20;
      speedFactor = 10;
      systems = [
        "x86_64-linux"
      ];
    }
     /*
     {
        hostName = "main";
        maxJobs = 4;
        systems = [
           "x86_64-linux"
        ];
     }
     */
  ];
	nix.settings = {
		trusted-public-keys = [
			"sebastian@c2vi.dev:0tIXGRJMLaI9H1ZPdU4gh+BikUuBVHtk+e1B5HggdZo="
		];
      #builders = "@/etc/nix/machines";
      trusted-users = [ "me" ];
	};
}
