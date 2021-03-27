{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bird_exporter";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "czerwonk";
    repo = pname;
    rev = version;
    hash = "sha256-qOj1RaYWO2XHZm+DaB1ajvUIYvdoJFIgHaulk3etNBs=";
  };
  vendorSha256 = "sha256-QELQFgviMCba6UJQKvdqoG1RVqTWgmqDfmntvrFrcpE=";

  doCheck = true;

  meta = with lib; {
    description = "Bird protocol state exporter for bird routing daemon to use with Prometheus";
    homepage = "https://github.com/czerwonk/bird_exporter";
    license = licenses.mit;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.unix;
  };
}
