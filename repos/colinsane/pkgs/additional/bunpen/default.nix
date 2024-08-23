{
  hareHook,
  stdenv,
}: stdenv.mkDerivation {
  pname = "bunpen";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ hareHook ];
  makeFlags = [ "PREFIX=${builtins.placeholder "out"}" ];

  doCheck = true;

  meta = {
    description = "userspace sandbox helper";
    longDescription = ''
      run any executable in an isolated environment,
      selectively exposing the specific resources (paths, IPC) it needs.
    '';
    mainProgram = "bunpen";
  };
}
