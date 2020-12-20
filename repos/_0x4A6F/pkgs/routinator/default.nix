{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "routinator";
  version = "0.8.2-rc1";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1mvv1878xy3yj01i0la0pp8b09zlnnwzgn69fjhkc3aahcfi41k2";
  };

  cargoSha256 = "1nmvdn4lizqwxsf320h1vh5cc8a56h6fp55fnkqpihjz2nh5y467";

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
