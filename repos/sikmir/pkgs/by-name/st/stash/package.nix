{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "stash";
  version = "0.21.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "stash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ltLn3k0HOxbCx37S271SS1ZmuySOK//lcG8vSwXklYk=";
  };

  vendorHash = null;

  subPackages = [ "app" ];

  ldflags = [
    "-s"
    "-X main.revision=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/{app,stash}
    installShellCompletion completions/*
  '';

  meta = {
    description = "Simple key-value configuration service";
    homepage = "https://github.com/umputun/stash";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "stash";
  };
})
