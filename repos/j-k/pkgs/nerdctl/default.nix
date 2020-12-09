{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nerdctl";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "AkihiroSuda";
    repo = pname;
    rev = "v${version}";
    sha256 = "010kyzanhlnwsc322l2xmmhn7mf4pgk4m14gid1w669nj0ikzhrj";
  };

  vendorSha256 = "0j374wvz1jv1b9w5qk4jy5djrcs2sbswjgaj9xz8vqhvqdf3vbbn";

  buildFlagsArray = [ "-ldflags=" "-w" "-s" ];

  meta = with lib; {
    homepage = src.meta.homepage;
    description = "A Docker-compatible CLI for containerd";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jk ];
  };
}
