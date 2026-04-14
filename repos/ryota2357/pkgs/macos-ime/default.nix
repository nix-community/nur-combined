{
  lib,
  stdenv,
  installShellFiles,
  source,
}:

stdenv.mkDerivation {
  inherit (source) pname src;
  version = "unstable-${source.date}";

  nativeBuildInputs = [ installShellFiles ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 build/ime -t $out/bin

    installShellCompletion --cmd ime \
      --bash completions/ime.bash \
      --zsh  completions/_ime \
      --fish completions/ime.fish

    runHook postInstall
  '';

  doCheck = true;

  meta = {
    description = "Tiny macOS CLI to get, set, and list keyboard input sources";
    homepage = "https://github.com/ryota2357/macos-ime";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "ime";
  };
}
