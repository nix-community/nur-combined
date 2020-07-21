{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "yubikey-touch-detector";
  version = "1.5.0";

  goPackagePath = "github.com/maximbaz/yubikey-touch-detector";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "yubikey-touch-detector";
    rev = version;
    sha256 = "1c6848brg1wvli69vywn0if15ymwhfpnkni8fawi0qbda8mpy7f2";
  };

  modSha256 = "126w3wda3655x1avnlcv2bpq0zvalcbvz66080nidwd6fk572zs6";
  vendorSha256 = null;

  meta = with stdenv.lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = https://github.com/maximbaz/yubikey-touch-detector;
  };
}
