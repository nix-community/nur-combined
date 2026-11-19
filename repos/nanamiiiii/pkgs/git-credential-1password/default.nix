{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "git-credential-1password";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "ethrgeist";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-I6/yVXOJDsDz/ZC3AkOzbbqaSVw51OWjWe7FFsxsjnc=";
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
