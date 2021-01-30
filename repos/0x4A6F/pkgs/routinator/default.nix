{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "routinator";
  version = "0.8.3-rc1";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1v9sq3lw112mjxpxgv5spk7r18ky7v9mvfh0kd6nh35w0dswic8n";
  };

  cargoSha256 = "1rgb905fwslqcf24jd9i4bcr6i68ji1mzsriccvllvyy0wkdwkgl";

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

  meta = with stdenv.lib; {
    description = "An RPKI Validator written in Rust";
    homepage = "https://github.com/NLnetLabs/routinator";
    license = licenses.bsd3;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
