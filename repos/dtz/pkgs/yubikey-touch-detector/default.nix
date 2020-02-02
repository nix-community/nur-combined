{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "yubikey-touch-detector";
  version = "1.4.1";

  goPackagePath = "github.com/maximbaz/yubikey-touch-detector";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "yubikey-touch-detector";
    rev = version;
    sha256 = "1h2shjf0vahlz3xb9144i2azrz5g7n1iw6a7nhim3w3r8m12wnsv";
  };

  modSha256 = "126w3wda3655x1avnlcv2bpq0zvalcbvz66080nidwd6fk572zs6";

  meta = with stdenv.lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = https://github.com/maximbaz/yubikey-touch-detector;
  };
}
