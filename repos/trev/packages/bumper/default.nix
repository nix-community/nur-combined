{
  autoPatchelfHook,
  fetchFromGitHub,
  lib,
  libgcc,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  buildRustPackage ? rustPlatform.buildRustPackage,
}:

buildRustPackage (finalAttrs: {
  pname = "bumper";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KO1LwANB1kuG5xhOB242ydg+vyDIuQwQce9/TVUq6tI=";
  };

  cargoHash = "sha256-X5eFClOa2fIU/pJOhfy3b7KBX3Cg98QJMJDP70tMub8=";

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional (!stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isLinux) autoPatchelfHook;

  buildInputs = [
    libgcc
    openssl
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Git semantic version bumper";
    mainProgram = "bumper";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/bumper";
    changelog = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
  };
})
