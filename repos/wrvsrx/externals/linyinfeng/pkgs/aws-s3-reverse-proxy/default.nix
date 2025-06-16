{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "aws-s3-reverse-proxy";
  version = "1.1.1-patched.3";
  src = fetchFromGitHub {
    owner = "linyinfeng";
    repo = "aws-s3-reverse-proxy";
    rev = "v${version}";
    sha256 = "sha256-ntpXMQ+AGUOiKw1Uh/6Yw5vvJ1t8T3S8OFsHK7njR3g=";
  };

  vendorHash = "sha256-vwGdGjMNCQfFRROL1Pf4AMIQy0gDrCLKHniteiiVZ8c=";

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
