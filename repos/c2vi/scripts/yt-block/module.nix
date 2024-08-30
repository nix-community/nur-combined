{ pkgs, config, ... }:
let 
	yt_block = pkgs.callPackage ./app.nix {};
in {
	systemd.services.yt-block = {
		 enable = true;
		 description = "Block Youtube";
		 serviceConfig = {
			Restart = "always";
			#RestartSec = "60s";
			ExecStart = "${yt_block}/bin/yt_block starter";
		 };
		 wantedBy = [ "multi-user.target" ];
	};
  environment.systemPackages = [ yt_block ];

  boot.extraModulePackages = [ (pkgs.callPackage ./unkillable-process-kernel-module.nix { 
    kernel = config.boot.kernelPackages.kernel;
  }) ];
  boot.kernelModules = [ "unkillable" ];
}
