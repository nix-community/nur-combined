{
  hareHook,
  stdenv,
  which,
}: stdenv.mkDerivation {
  pname = "bunpen";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ hareHook ];
  makeFlags = [ "PREFIX=${builtins.placeholder "out"}" ];

  nativeCheckInputs = [ which ];

  # doCheck = true;  #< TODO: fix tests!

  meta = {
    description = "userspace sandbox helper";
    longDescription = ''
      run any executable in an isolated environment,
      selectively exposing the specific resources (paths, IPC) it needs.
    '';
    mainProgram = "bunpen";
  };
}
