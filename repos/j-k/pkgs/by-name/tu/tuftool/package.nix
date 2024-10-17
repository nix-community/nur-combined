{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
,
}:

rustPlatform.buildRustPackage rec {
  pname = "tuftool";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "tough";
    rev = "tuftool-v${version}";
    hash = "sha256-B4amCeePbF72zdTUC5PyT90ZVyMSEPOzJ4Vjsbh3Bl0=";
  };

  cargoHash = "sha256-p59RY2HpmYFK67+dwB6Dsy6+cZSUBgBGlELTnV5FkVo=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  buildAndTestSubdir = "tuftool";

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/tuftool --help
    $out/bin/tuftool --version | grep "${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/awslabs/tough/";
    changelog = "https://github.com/awslabs/tough/blob/tuftool-v${version}/tuftool/CHANGELOG.md";
    description = "A Rust command-line utility for generating and signing TUF repositories";
    license = with licenses; [
      asl20
      # or
      mit
    ];
    maintainers = with maintainers; [ jk ];
  };
}
