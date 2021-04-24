{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "reproxy";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6NjW/JnHVspGZAOiPOkOztJmqLlmjJZm9vuL/fN94Jc=";
  };

  vendorSha256 = null;

  doCheck = false;

  postInstall = "mv $out/bin/{app,reproxy}";

  meta = with lib; {
    description = "Simple edge server / reverse proxy";
    homepage = "http://reproxy.io/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
