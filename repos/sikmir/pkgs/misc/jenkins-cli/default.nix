{ lib, buildGoModule, fetchFromGitHub, fetchpatch }:

buildGoModule rec {
  pname = "jenkins-cli";
  version = "0.0.40";

  src = fetchFromGitHub {
    owner = "jenkins-zh";
    repo = "jenkins-cli";
    rev = "v${version}";
    hash = "sha256-ovrli7C4OyWAQSAOm1aoO/s/lHP1uI8XhnywkCxylIk=";
  };

  patches = [
    # Fix artifact download url construction
    (fetchpatch {
      url = "https://github.com/jenkins-zh/jenkins-cli/commit/cb4c34cc5e7853444939af3643cf64d69095dc41.patch";
      hash = "sha256-6hWtHXwg6CmRJBX12IVsQhJPK/Xlv8zrLDltZHN2i6U=";
    })
  ];

  vendorHash = "sha256-bmPnxFvdKU5zuMsCDboSOxP5f7NnMRwS/gN0sW7eTRA=";

  doCheck = false;

  meta = with lib; {
    description = "Jenkins CLI allows you to manage your Jenkins in an easy way";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
