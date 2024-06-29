{ lib, stdenvNoCC

, fetchurl

, installShellFiles

, withNode ? true, nodejs
}: stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pnpm";
  version = "9.3.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/pnpm/-/pnpm-${finalAttrs.version}.tgz";
    hash = "sha256-4fno0aFmB6Rt08FYtfen3HlFUB0cYiLUVNY9Az0dkY8=";
  };

  # Remove binary files from src, we don't need them, and this way we make sure
  # our distribution is free of binaryNativeCode
  preConfigure = ''
    rm -r dist/reflink.*node dist/vendor
  '';

  buildInputs = lib.optionals withNode [ nodejs ];

  nativeBuildInputs = [ installShellFiles nodejs ];

  installPhase = ''
    runHook preInstall

    install -d $out/{bin,libexec}
    cp -R . $out/libexec/pnpm
    ln -s $out/libexec/pnpm/bin/pnpm.cjs $out/bin/pnpm
    ln -s $out/libexec/pnpm/bin/pnpx.cjs $out/bin/pnpx

    runHook postInstall
  '';

  postInstall = ''
    node $out/bin/pnpm completion bash >pnpm.bash
    node $out/bin/pnpm completion fish >pnpm.fish
    node $out/bin/pnpm completion zsh >pnpm.zsh
    sed -i '1 i#compdef pnpm' pnpm.zsh
    installShellCompletion pnpm.{bash,fish,zsh}
  '';

  meta = with lib; {
    description = "Fast, disk space efficient package manager for JavaScript";
    homepage = "https://pnpm.io/";
    changelog = "https://github.com/pnpm/pnpm/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = with maintainers; [ Scrumplex ];
    platforms = platforms.all;
    mainProgram = "pnpm";
  };
})
