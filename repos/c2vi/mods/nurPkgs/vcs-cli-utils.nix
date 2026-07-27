{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
	pname = "vcs-cli-utils";
	version = "1.0.4";

	src = fetchFromGitHub {
		owner = "henkelmax";
		repo = "svc-cli-utils";
    rev = "${version}";
    sha256 = "sha256-vRqYQd5OaYXAc74Jlg8twBGDr9YxP+Mk1ZY9JGJTmvc=";
	};

  cargoHash = "sha256-RoDXIPCjygdmG9dfDMtKiSdj2rgDAfxkKUXkIUAWotI=";

  meta = with lib; {
    description = "Command line utilities for the Simple Voice Chat Minecraft Mod";
    longDescription = ''
      Simple Voice Chat Mod: https://github.com/henkelmax/simple-voice-chat
    '';
    homepage = "https://github.com/henkelmax/svc-cli-utils";
    #maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "svc";
  };
}
