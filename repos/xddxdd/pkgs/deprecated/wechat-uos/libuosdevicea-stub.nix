{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "libuosdevicea-stub";
  version = "1.0";
  src = fetchurl {
    name = "libuosdevicea.c";
    url = "https://aur.archlinux.org/cgit/aur.git/plain/libuosdevicea.c?h=wechat-universal";
    sha256 = "1y1qh6q7z6zkih32shk4hqm2nfvksd2big9y4d4y2gpfipmyjg7w";
  };
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    cc ''${CFLAGS} ''${LDFLAGS} -fPIC -shared $src -o libuosdevicea.so

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 libuosdevicea.so $out/lib/libuosdevicea.so

    runHook postInstall
  '';
}
