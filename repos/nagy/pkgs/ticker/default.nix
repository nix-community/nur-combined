{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.1.5";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "1nzsxyibsss7v4m453qbdd5yc2qikhi84dlp039hrhr60n5k5wbg";
  };

  vendorSha256 = "16nmhy8wkcg29fypvh2kbq93wb18pxlhkdawxyffa1cnj7nn6h39";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3Only;
  };
}
