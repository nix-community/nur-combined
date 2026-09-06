{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "on-demand-scroll-bar";
  version = "0.1-unstable-2024-01-30";

  src = fetchFromGitHub {
    owner = "florommel";
    repo = "on-demand-scroll-bar";
    rev = "46df83135997b8957ea2a09d28d82ca6faccf984";
    hash = "sha256-CjN1/6AoQ2T8d8Kbg0PKRLdRBDdAoDkKMD4GPk83Mj4=";
  };

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/florommel/on-demand-scroll-bar";
    description = "Show native scroll bars only when the buffer is not fully visible";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
