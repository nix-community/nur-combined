{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "aws-s3-reverse-proxy";
  version = "1.1.1-patched.4";
  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "aws-s3-reverse-proxy";
    rev = "v${version}";
    sha256 = "sha256-11gWCUqv4SgxbUZtkQoD0nIrOoxZh2ZXfqlK+Fp4KOY=";
  };

  vendorHash = "sha256-aH3BhRyu09XAGQns3BF/yxIdPCXWrK0GewUO/xcjR0A=";

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "Reverse-proxy all incoming S3 API calls to the public AWS S3 backend";
    homepage = "https://github.com/Kriechi/aws-s3-reverse-proxy";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
