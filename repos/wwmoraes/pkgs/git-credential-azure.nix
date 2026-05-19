{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (finalAttrs: {
  pname = "git-credential-azure";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "hickford";
    repo = "git-credential-azure";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/N+KZU89QUc4qEbZwnHjvbdbobvGXZqEekszlDN9AI4=";
  };

  vendorHash = "sha256-Gpl4PE+tlC3LtdDUCZMgi16qvQfYk8RHJJuMmZOZK98=";

  doInstallCheck = true;
  postCheckInstall = ''
    		$out/bin/git-credential-azure --help
    	'';

  meta = with lib; {
    description = "A Git credential helper for Azure Repos";
    homepage = "https://github.com/hickford/git-credential-azure";
    license = licenses.asl20;
    mainProgram = "git-credential-azure";
    maintainers = with maintainers; [ wwmoraes ];
    platforms = platforms.all;
  };
})
