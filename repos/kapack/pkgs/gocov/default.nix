{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gocov";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "axw";
    repo = pname;
    rev = "v${version}";
    sha256 = "14dsbabp1h31zzx7xlzg604spk3k3a0wpyq9xsrpqr8hz425h9xv";
  };

  vendorSha256 = "1hkfj18sshn8z0w1njgrwzchagxz1fmpq26a1wsf47xd64ydzwi1";

  meta = with lib; {
    description = "Coverage testing tool for The Go Programming Language.";
    longDescription = ''
      Coverage testing tool for The Go Programming Language.
    '';
    license = licenses.mit;
    broken = false;
    maintainers = with maintainers; [ mpoquet ];
    platforms = platforms.all;
    homepage = "https://github.com/axw/gocov";
  };
}
