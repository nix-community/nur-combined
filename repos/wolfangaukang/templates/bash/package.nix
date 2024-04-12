{ lib
, resholve
, bash
}:

resholve.mkDerivation {
  pname = "project";
  version = "0.0.1";

  src = lib.cleanSource ./.;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 script.sh $out/bin/script

    runHook postInstall
  '';

  solutions.default = {
    scripts = [ "bin/script" ];
    interpreter = "${lib.getExe bash}";
    inputs = [ ];
    fake = {
      #external = [ "echo" ];
    };
  };
}
