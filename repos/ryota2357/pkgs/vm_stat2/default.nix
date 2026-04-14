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

    install -Dm755 build/vm_stat2 -t $out/bin

    installShellCompletion --cmd vm_stat2 \
      --bash completions/vm_stat2.bash \
      --zsh  completions/_vm_stat2 \
      --fish completions/vm_stat2.fish

    runHook postInstall
  '';

  doCheck = true;

  meta = {
    description = "An improved vm_stat command for macOS";
    homepage = "https://github.com/ryota2357/vm_stat2";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "vm_stat2";
  };
}
