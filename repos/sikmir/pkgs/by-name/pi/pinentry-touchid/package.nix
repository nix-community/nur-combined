{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "pinentry-touchid";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "jorgelbg";
    repo = "pinentry-touchid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XMcJjVVAp5drLMVTShITl0v6uVazrG1/23dVerrsoj4=";
  };

  vendorHash = "sha256-PJJoTnA9WXzH9Yv/oZfwyjjcbvJwpXxX81vpzTtXWxU=";

  subPackages = [ "." ];

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  doCheck = false;

  meta = {
    description = "Custom GPG pinentry program for macOS that allows using Touch ID";
    homepage = "https://github.com/jorgelbg/pinentry-touchid";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.darwin;
    skip.ci = !stdenv.isDarwin;
  };
})
