{
  lib,
  buildDubPackage,
  fetchFromGitHub,
  ldc,
}:

buildDubPackage rec {
  pname = "trash-d";
  version = "21";

  src = fetchFromGitHub {
    owner = "rushsteve1";
    repo = "trash-d";
    rev = version;
    hash = "sha256-/spFB2/LUbf/uWAZQ88Y5HIPLCPmN/KJpyUTvzICyHM=";
  };

  dubLock = {
    dependencies = { };
  };

  compiler = ldc;

  # disable static linking: stdenv has no static glibc/pthread
  postPatch = ''
    substituteInPlace dub.json \
      --replace-fail '"dflags-linux-ldc": ["-static"]' '"dflags-linux-ldc": []'
  '';

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
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
