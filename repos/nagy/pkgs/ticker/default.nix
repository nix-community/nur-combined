{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "10y568ms7s7a0y2sn2v826l8gjr92ddisjb1y84x96k7758b7zzl";
  };

  vendorSha256 = "0ckx5wws467d38fkk4ijcgk43whs95mgp5vgqn9j2s5kgw0qj17b";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
