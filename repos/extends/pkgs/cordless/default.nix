{ stdenv, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "cordless";
  version = "2020-08-30";

  src = fetchFromGitHub {
    owner = "Bios-Marcel";
    repo = "cordless";
    rev = "${version}";
    sha256 = "0x57czyr5cgwk7bjg42qyiffq848fnczm3jii5pn7ixkz5hv09dx";
  };

  vendorSha256 = "16g3arpfmm169lxjy14xf6yqrxpaldkh8y6jd2mfzjk5594m5kgj";

  meta = with stdenv.lib; {
    description = "Discord client for terminals";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.bsd3;
    maintainers = with maintainers; [ extends ];
    platforms = platforms.all;
  };
}
