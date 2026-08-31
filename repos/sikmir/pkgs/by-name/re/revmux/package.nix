{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "revmux";
  version = "0.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revmux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-577D77h0vIDd0+9632B9Tv1fD3gtVcIbJzExyE6Iwao=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-X main.revision=v${finalAttrs.version}"
  ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/{app,revmux}
  '';

  meta = {
    description = "Multi-agent code review, supervised and auditable";
    homepage = "https://github.com/umputun/revmux";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "revmux";
  };
})
