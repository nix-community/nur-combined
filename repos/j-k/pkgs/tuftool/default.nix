{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "tuftool";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "tough";
    rev = "tuftool-v${version}";
    sha256 = "sha256-olI5i1YL05F8iVfBNjF8ebeMr2pCtGVOyP+2qAhZXRU=";
  };

  cargoSha256 = "sha256-+U4mFiQUhffzYDjUgefxV0QikIY+XoaV8zvtV+ph9o0=";

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
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ jk ];
  };
}
