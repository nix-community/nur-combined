{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "drep";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "maxpert";
    repo = pname;
    rev = "v${version}";
    sha256 = "035b0rssqk4dcv2q7r6drmk2iy1j12ayx9nfzf82w6vdadg58y4x";
  };

  cargoSha256 = "02rgy3wr9xl56pp9lc2rkz4zsrxfdwqxs3h7ppj2rnd6ij6rbc8h";

  meta = with lib; {
    description = "A grep with runtime reloadable filters";
    homepage = "https://github.com/maxpert/drep";
    license = licenses.mit;
    maintainers = with maintainers; [ AluisioASG ];
    platforms = platforms.all;
  };
}
