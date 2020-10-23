{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "routinator";
  version = "0.7.1-rc1";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "09l5z56xc0z93xfzj0cxgh2prp627dnbi4x0nzlkxrfzclyf0sid";
  };

  cargoSha256 = "1riysw4rmfqw3m94jag61g3j73488c6xdlxzw0hlkdv760zhb890";

  meta = with stdenv.lib; {
    description = "An RPKI Validator written in Rust";
    homepage = "https://github.com/NLnetLabs/routinator";
    license = licenses.bsd3;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
