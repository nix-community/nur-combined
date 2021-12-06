{ lib
, fetchFromGitHub
, rustPlatform
, routinator
, testVersion
}:

rustPlatform.buildRustPackage rec {
  pname = "routinator";
  version = "0.10.0-rc3";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "13mvx4wwwm0k30a6rajzk714vpz6slqa5bwzws27lxjjsrjqizni";
  };

  cargoSha256 = "1r5d2r127rp4vr2iy84mpvrsbr2b39p9n2v6xf097mbbag2cpm90";

  passthru.tests = testVersion { package = routinator; };

  meta = with lib; {
    description = "An RPKI Validator written in Rust";
    homepage = "https://github.com/NLnetLabs/routinator";
    license = licenses.bsd3;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
