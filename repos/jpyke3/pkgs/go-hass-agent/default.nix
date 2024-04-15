{ lib
, buildGo122Module
, fetchFromGitHub
}:

buildGo122Module rec {
	pname = "go-hass-agent";
	version = "7.3.0";

	src = fetchFromGitHub {
		owner = "joshuar";
		repo = "go-hass-agent";
		rev = "v7.3.0";
		sha256 = "sha256-lgqHz97VFLBBGCtFZQNvqalqYbMsbKY4DBv/95DEXas=";
	};

	vendorHash = "sha256-6RYHZiA/6lxPMIoLR9Yk3LiPLK9GszHiACN20h/Da2E=";

	subPackages = [ "cmd" ];

	postConfigure = ''
		go generate ./...
	'';

	meta = with lib; {
		description = "A Home Assistant, native app integration for desktop/laptop devices.";
		homepage = "https://github.com/joshuar/go-hass-agent";
		changeLog = "https://github.com/joshuar/go-hass-agent/releases/tag/v${version}";
		licence = licenses.mit;
		maintainers = with maintainers; [ jpyke3 ];
		mainProgram = "go-hass-agent";
		broken = true; # Still haven't figured out how to handle the other depenedencies
	};
}

