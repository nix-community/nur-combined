{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
	pname = "vcs-cli-utils";
	version = "0.3.2";

	src = fetchFromGitHub {
		owner = "henkelmax";
		repo = "svc-cli-utils";
    rev = "master";
    sha256 = "sha256-37kyRO0ojhzJgctbopVyLA0ttK/vYTMIoGYFdZy6hy4=";
	};

  cargoHash = "sha256-h2AqkDo9Lvi6G0ZUk+MlzXeFwC/d9AKKWgXUPqSUOEs=";

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
