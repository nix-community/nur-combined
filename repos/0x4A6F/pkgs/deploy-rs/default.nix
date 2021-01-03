{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "deploy-rs";
  version = "unstable-2021-01-02";

  src = fetchFromGitHub {
    owner = "serokell";
    repo = pname;
    rev = "4ba83f14ceb7136794e7676b71688b903d2c60ab";
    sha256 = "15lrh9b2qhwp0vqhh3vj1bcjl9cpnsv7myizm4ram0hva53s8fcd";
  };

  cargoSha256 = "0655ipgmsx8ky1ikf5hwlqiwfyla80kp0fmppzzg9dr2js7svw4c";

  doInstallCheck = true;
  installCheckPhase = ''
    if [[ "$("$out/bin/deploy" --version)" == "deploy-rs 1.0" ]]; then
      $out/bin/deploy --help | grep -q $pname
      echo '${pname} smoke check passed'
    else
      echo '${pname} smoke check failed'
      return 1
    fi
  '';

  meta = with stdenv.lib; {
    description = "A simple multi-profile Nix-flake deploy tool.";
    homepage = "https://github.com/serokell/deploy-rs";
    license = licenses.mpl20;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
