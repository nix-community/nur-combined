{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "duf";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "muesli";
    repo = pname;
    rev = "v${version}";
    sha256 = "1szzppriwy20f87bgjanvvfv7xl7j8d29agwibjrdyjqx3hdrzjj";
  };

  vendorSha256 = "1pm3inyyd57xgi4v2yb3ln0m5qs0sw7w1rw8cph6v5k7aw5x8nh3";

  meta = with lib; {
    description = "Disk Usage/Free Utility - a better 'df' alternative";
    homepage = "https://github.com/muesli/duf";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
