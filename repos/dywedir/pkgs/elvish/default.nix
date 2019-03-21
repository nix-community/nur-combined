{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "elvish-unstable";
  version = "2019-03-19";

  goPackagePath = "github.com/elves/elvish";
  excludedPackages = [ "website" ];
  buildFlagsArray = ''
    -ldflags=
      -X ${goPackagePath}/buildinfo.Version=${version}
  '';

  src = fetchFromGitHub {
    owner = "elves";
    repo = "elvish";
    rev = "71d050b31c1578b763cf9d6cdae50ca6fcc2956a";
    sha256 = "0whkcn89jy6bav84xgk5kppck88g1k2ajl5w90nncvy3mzdcp7jw";
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
