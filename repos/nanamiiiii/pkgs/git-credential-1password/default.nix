{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "git-credential-1password";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "ethrgeist";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-FkmhnU8w51LzBMIFd1385gAaTl9O5G2JuFtnsN2zWTo=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "A git credential helper for 1Password";
    homepage = "https://github.com/ethrgeist/git-credential-1password";
    changelog = "https://github.com/ethrgeist/git-credential-1password/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "git-credential-1password";
  };
}
