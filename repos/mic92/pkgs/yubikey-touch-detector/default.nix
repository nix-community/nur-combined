{ lib, buildGoModule, fetchFromGitHub
, pkg-config, libnotify
}:

buildGoModule rec {
  name = "yubikey-touch-detector-${version}";
  version = "1.9.0";
  rev = "9c160b4a7d5761c518af5d1eaa4a671aa449e773";

  src = fetchFromGitHub {
    owner = "maximbaz";
    repo = "yubikey-touch-detector";
    rev = version;
    sha256 = "sha256-mRuvMAXeFrc7qJuBGeK94ef+bSM/axOy2BapJRy1sxs=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libnotify ];

  vendorHash = "sha256-dJPfvMaGo1mcRkwQll1DcK+4PaWabfCgy7rV6D4V59Q=";

  meta = with lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = "https://github.com/maximbaz/yubikey-touch-detector";
  };
}
