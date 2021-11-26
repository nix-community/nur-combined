{ buildGoModule, fetchFromGitHub, lib }:
buildGoModule rec {
  pname = "muun-recovery-tool";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "muun";
    repo = "recovery";
    rev = "v${version}";
    sha256 = "sha256-I0UAknd6Q+514QfToiOWhxc93h4ahpr1zm1RolEl3sk=";
  };

  vendorSha256 = null;
  runVend = false;

  meta = with lib; {
    description = "You can use this Recovery Tool to transfer all funds out of your Muun account to an address of your choosing";
    homepage = "https://muun.com";
    license = licenses.mit;
    maintainers = with maintainers; [ emmanuelrosa ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
