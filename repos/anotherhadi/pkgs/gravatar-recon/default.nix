{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "gravatar-recon";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "gravatar-recon";
    rev = "v${version}";
    hash = "sha256-pM9IvpzZVaQcX62r/oI6+LNT7cYP7WfnAcGGi27SY9w=";
  };

  vendorHash = "sha256-hjaIXZMK9+b+tlWD55OU3mS0CLUA/Oonn/RBHQdgs2g=";

  subPackages = ["cmd"];

  ldflags = ["-s" "-w"];

  postInstall = ''
    mv $out/bin/cmd $out/bin/gravatar-recon
  '';

  meta = with lib; {
    description = " Retrieve and aggregate public OSINT data from Gravatar. Given an email address, the tool queries the Gravatar API and extracts useful information such as profile metadata, avatar, social accounts, and contact info.";
    homepage = "https://github.com/anotherhadi/gravatar-recon";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "gravatar-recon";
  };
}
