{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "docker-reg-tool";
  version = "0-unstable-2023-10-26";

  src = fetchFromGitHub {
    owner = "byrnedo";
    repo = "docker-reg-tool";
    rev = "ff27e94d2cf97dfd078d37aa156ab720aa32da29";
    hash = "sha256-Tcdu7GwmV/kAe4yxzGFr05wC0DpAjkbUNPXG8EhBU2E=";
  };

  installPhase = ''
    install -Dm755 docker_reg_tool -t $out/bin
  '';

  meta = {
    description = "Docker registry cli tool, primarily for deleting images";
    homepage = "https://github.com/byrnedo/docker-reg-tool";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
}
