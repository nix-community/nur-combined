{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  darwin,
}:

buildGoModule rec {
  pname = "pinentry-touchid";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "jorgelbg";
    repo = "pinentry-touchid";
    rev = "v${version}";
    hash = "sha256-XMcJjVVAp5drLMVTShITl0v6uVazrG1/23dVerrsoj4=";
  };

  vendorHash = "sha256-PJJoTnA9WXzH9Yv/oZfwyjjcbvJwpXxX81vpzTtXWxU=";

  subPackages = [ "." ];

  buildInputs = [ darwin.apple_sdk.frameworks.LocalAuthentication ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  doCheck = false;

  meta = {
    description = "Custom GPG pinentry program for macOS that allows using Touch ID";
    homepage = "https://github.com/jorgelbg/pinentry-touchid";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.darwin;
    skip.ci = !stdenv.isDarwin;
  };
}
