{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "k380-function-keys-conf";
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
  meta = with stdenv.lib; {
    description = "Make function keys default on Logitech k380 bluetooth keyboard";
    license = licenses.gpl3;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
