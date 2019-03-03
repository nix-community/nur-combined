{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "elvish-unstable";
  version = "2019-02-04";

  goPackagePath = "github.com/elves/elvish";
  excludedPackages = [ "website" ];
  buildFlagsArray = ''
    -ldflags=
      -X ${goPackagePath}/buildinfo.Version=${version}
  '';

  src = fetchFromGitHub {
    owner = "elves";
    repo = "elvish";
    rev = "06abd5dbc55b6e069e0fbc4328c3414ad4634aa4";
    sha256 = "1xcbqsl7w5vv1j5bplm7ql51b00mm4xm2zmjy0bmlpzp8g192gh0";
  };

  meta = with stdenv.lib; {
    description = "A friendly and expressive command shell";
    longDescription = ''
      Elvish is a friendly interactive shell and an expressive programming
      language. It runs on Linux, BSDs, macOS and Windows. Despite its pre-1.0
      status, it is already suitable for most daily interactive use.
    '';
    homepage = https://elv.sh/;
    license = licenses.bsd2;
    maintainers = with maintainers; [ vrthra AndersonTorres ];
    platforms = with platforms; linux ++ darwin;
  };

  passthru = {
    shellPath = "/bin/elvish";
  };
}
