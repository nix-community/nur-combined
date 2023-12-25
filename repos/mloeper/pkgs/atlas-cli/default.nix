{ stdenv
, autoPatchelfHook
, fetchurl
, libgcc
, lib
, installShellFiles
}:
stdenv.mkDerivation rec {
  name = "atlas-cli";
  version = "1.14.0";
  src = fetchurl {
    url = "https://fastdl.mongodb.org/mongocli/mongodb-atlas-cli_${version}_linux_x86_64.tar.gz";
    sha256 = "mgQzieVAZwzxwM3kn3hU0le37YlYthKQlgFUtdrcBq4=";
  };
  buildInputs = [
    libgcc
  ];
  nativeBuildInputs = [ installShellFiles autoPatchelfHook ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    tar -zxvf $src -C $out
    mv $out/mongodb-atlas-cli_${version}_linux_x86_64/bin/atlas $out/bin/atlas
    rm -R $out/mongodb-atlas-cli_${version}_linux_x86_64

    runHook postInstall;
  '';
  postInstall = ''
    mkdir -p share/completions
    $out/bin/atlas completion bash > share/completions/atlas-cli.bash
    $out/bin/atlas completion zsh > share/completions/atlas-cli.zsh
    $out/bin/atlas completion fish > share/completions/atlas-cli.fish

    installShellCompletion share/completions/atlas-cli.{bash,fish,zsh}
  '';
  meta = with lib; {
    homepage = "https://www.mongodb.com/docs/atlas/cli/stable/";
    description = "Interact with your Atlas database deployments and Atlas Search from the terminal";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "atlas";
  };
}
