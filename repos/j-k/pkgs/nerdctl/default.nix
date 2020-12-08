{ lib, buildGoModule, fetchgit }:

buildGoModule rec {
  pname = "nerdctl";
  version = "4ea21b339f96681a3493668a186c0e313a5efbdd";

  src = fetchgit {
    url = "https://github.com/AkihiroSuda/${pname}.git";
    rev = version;
    sha256 = "0hppbv2scp35q7q0iwbmfwfy5pv1bb9zahga7jv4yxpwy78fqsij";
  };

  vendorSha256 = "0d74f663zi6dhlm0m0i1jy5zm1rs331vcs8sppkv6bn9l6fjk554";

  buildFlagsArray = [ "-ldflags=" "-w" "-s" ];

  meta = with lib; {
    homepage = "https://github.com/AkihiroSuda/nerdctl";
    description = "A Docker-compatible CLI for containerd";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jk ];
  };
}
