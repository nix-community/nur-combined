{
  lib,
  buildDubPackage,
  fetchFromGitHub,
  dmd,
}:

buildDubPackage rec {
  pname = "trash-d";
  version = "19";

  src = fetchFromGitHub {
    owner = "rushsteve1";
    repo = "trash-d";
    rev = version;
    hash = "sha256-jvtBbQSKKib+MkI39YRk9jAo4Ij2X5KViiX4RbELUtI=";
  };

  dubLock = {
    dependencies = { };
  };

  compiler = dmd;

  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 build/trash -t $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "A near drop-in replacement for rm that uses the trash bin. Written in D.";
    homepage = "https://github.com/rushsteve1/trash-d";
    license = licenses.mit;
    maintainers = with maintainers; [ lunik1 ];
    platforms = [ "x86_64-linux" ];
  };
}
