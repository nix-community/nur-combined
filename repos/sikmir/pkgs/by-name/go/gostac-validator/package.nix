{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gostac-validator";
  version = "0.1.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "StacLabs";
    repo = "gostac-validator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-arB9xrb8hzJHktX0EtdTYTkztZy6qchMjjHhmR2HhuA=";
  };

  vendorHash = "sha256-+c09dVmdcnnH+BsHJdzttI8e47kz5kLo7Cm2hyUOgTE=";

  checkFlags = [ "-skip=TestValidate" ]; # requires network

  postInstall = ''
    mv $out/bin/{,stac-}cli
    mv $out/bin/{,stac-}server
  '';

  meta = {
    description = "A STAC validator built in Golang";
    homepage = "https://github.com/StacLabs/gostac-validator";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
