{ stdenv, fetchFromGitHub, buildGoModule }:
buildGoModule rec {
  pname = "cordless";
  version = "2020-08-30";

  src = fetchFromGitHub {
    owner = "Bios-Marcel";
    repo = "cordless";
    rev = "${version}";
    sha256 = "CwOI7Ah4+sxD9We+Va5a6jYat5mjOeBk2EsOfwskz6k=";
  };

  vendorSha256 = "01I7GrZkaskuz20kVK2YwqvP7ViPMlQ3BFaoLHwgvOE=";

  meta = with stdenv.lib; {
    description = "Discord client for terminals";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.bsd3;
    maintainers = with maintainers; [ extends ];
    platforms = platforms.all;
  };
}
