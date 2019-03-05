{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "elvish-unstable";
  version = "2019-03-02";

  goPackagePath = "github.com/elves/elvish";
  excludedPackages = [ "website" ];
  buildFlagsArray = ''
    -ldflags=
      -X ${goPackagePath}/buildinfo.Version=${version}
  '';

  src = fetchFromGitHub {
    owner = "elves";
    repo = "elvish";
    rev = "6b900563e4eb9202b51e35a3060496820dbf3ed7";
    sha256 = "0j71f4xqyz1hyj72rj3gb3vby2fadfp97f79v0z4x2pnlrbyh8zd";
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
