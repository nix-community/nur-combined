{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "airscan";
  version = "dev-d5c5aa4b";

  src = fetchFromGitHub {
    owner = "stapelberg";
    repo = "airscan";
    rev = "d5c5aa4ba0f225db27c8df4d442c72bc515b05cd";
    sha256 = "1i1snjp278i2hnshjnwy36ivc08yaw6q1d5bzjpjkg0ap6wfmhi7";
  };

  vendorSha256 = "0vnqpqirjd2d7xgrb9q0v6cz7pgqv9farj68pcr1bdrcgsbwipcd";


  meta = with lib; {
    homepage    = "https://github.com/stapelberg/airscan";
    description = "The airscan Go package can be used to scan paper documents from a scanner via he network using the Apple AirScn (eSCL) protocol.";
    maintainers = with maintainers; [ moredread ];
    license     = licenses.asl20;
  };
}
