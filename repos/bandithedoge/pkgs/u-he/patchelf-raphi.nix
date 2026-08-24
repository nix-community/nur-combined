{
  fetchFromSourcehut,
  stdenv,

  autoreconfHook,
}:
stdenv.mkDerivation {
  name = "patchelf-raphi";
  src = fetchFromSourcehut {
    owner = "~raphi";
    repo = "patchelf";
    rev = "9079354d2b94050f38594b5fab5f764f73e4b7e0";
    hash = "sha256-fJXkByP2QXo/3tpP1mPCYKmGolwlWLxubGV6xdytmCg=";
  };
  nativeBuildInputs = [ autoreconfHook ];
  meta.mainProgram = "patchelf";
}
