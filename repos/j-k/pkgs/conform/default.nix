{ lib, buildGoModule, fetchFromGitHub, git }:

buildGoModule rec {
  pname = "conform";
  version = "0.1.0-alpha.20";

  src = fetchFromGitHub {
    owner = "talos-systems";
    repo = pname;
    rev = "v${version}";
    sha256 = "0c2nzlbdirsa7w5zs06vlqsc6z2yi5ic3dzwad8shizxa4pv3q2m";
  };

  vendorSha256 = "18vhxq475d1f5sghy8gxa4wg6dbfj103pbl0kfx6xl6jf2ksqiln";

  nativeBuildInputs = [ git ];

  buildFlagsArray = [
    "-ldflags="
    "-s"
    "-w"
    "-X github.com/talos-systems/${pname}/cmd.Tag=v${version}"
  ];

  meta = with lib; {
    description = "Policy enforcement for your pipelines";
    longDescription = "Conform is a tool for enforcing policies on your build pipelines";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ jk ];
  };
}
