{ lib
, stdenv
, fetchFromGitHub
  # Native Build Inputs
, readline
, pkg-config
  # Dependencies
, lua5
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "luaprompt";
  version = "0.8-1";

  src = fetchFromGitHub {
    owner = "dpapavas";
    repo = "luaprompt";
    rev = "v0.8";
    hash = "sha256-GdI5sj7FBeb9q23oxVOzT+yVhMYTnggaN8Xt/z/2xZo=";
  };

  nativeBuildInputs = [
    pkg-config
    readline.dev
  ];

  buildInputs = [
    readline
    lua5
  ];

  makeFlags = [ "PREFIX=$(out)" "INSTALL=install" "VERSION=${let arr = (builtins.splitVersion lua5.version); in "${builtins.elemAt arr 0}.${builtins.elemAt arr 1}"}" ];

  meta = with lib; {
    homepage = "https://github.com/dpapavas/luaprompt";
    description = "A Lua command prompt with pretty-printing and auto-completion";
    license = licenses.mit;
    maintainers = with maintainers; [ Freed-Wu ];
  };
})
