{ stdenv, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "cordless";
  version = "2020-06-26";

  src = fetchFromGitHub {
    owner = "Bios-Marcel";
    repo = "cordless";
    rev = "daa4e6a1889acfd5393ea8695c86da724412ae1d";
    sha256 = "0x57czyr5cgwk7bjg42qyiffq848fnczm3jii5pn7ixkz5hv09dx";
  };

  vendorSha256 = "16g3arpfmm169lxjy14xf6yqrxpaldkh8y6jd2mfzjk5594m5kgj";

  meta = with stdenv.lib; {
    description = "Discord client for terminals";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.mit;
    maintainers = [ "Extends <sharosari@gmail.com>" ];
    platforms = platforms.all;
  };
}
