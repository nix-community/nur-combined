{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "routinator";
  version = "0.10.0-rc1";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1p76lr3kqbw6v2x5b6q2ml4hhf1v169fmjg5i53y3jzlb8jxqf4s";
  };

  cargoSha256 = "sha256:08jfzdflahx8qji6090hcfd1ji6bpibh1nyq0pqg8gz73r251j3q";

  doInstallCheck = true;
  installCheckPhase = ''
    if [[ "$("$out/bin/${pname}" --version)" == "Routinator ${version}" ]]; then
      $out/bin/${pname} config | grep -q log
      echo '${pname} smoke check passed'
    else
      echo '${pname} smoke check failed'
      return 1
    fi
  '';

  meta = with lib; {
    description = "An RPKI Validator written in Rust";
    homepage = "https://github.com/NLnetLabs/routinator";
    license = licenses.bsd3;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
