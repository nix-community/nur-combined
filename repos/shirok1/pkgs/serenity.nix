{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "serenity";
  version = "1.1.0-beta.3-dev";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "serenity";
    rev = "03df978c9ddd72125e373d5ef78c366cb1c24b6d";
    hash = "sha256-lNM6ZDzfBFb+/SG6HbvMCdvcwgjpUqE44NGRBYNg0uo=";
  };

  vendorHash = "sha256-o5w5uJHtSrNFTProi3XO51DWJ1hiESJ2y156uc4PTQs=";

  subPackages = [
    "cmd/serenity"
  ];

  env.CGO_ENABLED = 0;

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X=github.com/sagernet/serenity/constant.Version=${finalAttrs.version}"
  ];

  meta = {
    homepage = "https://serenity.sagernet.org";
    description = "Universal proxy platform";
    license = lib.licenses.gpl3Plus;
    mainProgram = "serenity";
  };
})
