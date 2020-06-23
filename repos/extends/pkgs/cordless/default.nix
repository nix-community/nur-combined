{ stdenv, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "cordless";
  version = "2020-01-05";

  src = fetchFromGitHub {
    owner = "Bios-Marcel";
    repo = "cordless";
    rev = "f7ad359ef872f600cab92f2e231ad009970059fd";
    sha256 = "05yvx43h5mivlyb5w52jy4njncbg295r46zf01is617kifpl23kg";
  };

  vendorSha256 = "156ny2bar1szrmm2fkbgdqx7828gnpawdcj703z74mzvxg30mwq0";

  meta = with stdenv.lib; {
    description = "Discord client for terminals";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.mit;
    maintainers = [ "Extends <sharosari@gmail.com>" ];
    platforms = platforms.all;
  };
}
