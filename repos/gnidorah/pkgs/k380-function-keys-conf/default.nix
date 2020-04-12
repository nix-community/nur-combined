{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "k380-function-keys-conf-${version}";
  version = "1.1";
  src = fetchFromGitHub {
    owner = "jergusg";
    repo = "k380-function-keys-conf";
    rev = "v${version}";
    sha256 = "0kfh1ixjxjx7h5pn7y95hk1lksx3pigl7id4ndspyad7bjmjdd93";
  };
  makeFlags = [
    "PREFIX=${placeholder "out"}" "UDEVDIR=${placeholder "out"}/etc/udev/rules.d"
  ];
}
