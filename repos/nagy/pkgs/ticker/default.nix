{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hsksax8fgp9x69lcijh34a4lsn9y9v00nc87ksr5s2z9vmvczsk";
  };

  vendorSha256 = "16nmhy8wkcg29fypvh2kbq93wb18pxlhkdawxyffa1cnj7nn6h39";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3Only;
  };
}
