{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "mqtt-benchmark";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "krylovsk";
    repo = "mqtt-benchmark";
    rev = "v${version}";
    hash = "sha256-gejLDtJ1geO4eDBapHjXgpc+M2TRGKcv5YzybmIyQSs=";
  };

  vendorHash = "sha256-ZN5tNDIisbhMMOA2bVJnE96GPdZ54HXTneFQewwJmHI=";

  meta = with lib; {
    description = "MQTT broker benchmarking tool";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
