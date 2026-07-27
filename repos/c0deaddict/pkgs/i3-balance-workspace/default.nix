{ lib
, buildPythonApplication
, fetchFromGitHub
, poetry-core
, i3ipc
}:

buildPythonApplication rec {
  pname = "i3-balance-workspace";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "atreyasha";
    repo = "i3-balance-workspace";
    rev = "v${version}";
    hash = "sha256-81uQYcAyAsYF4hP6vRpaIolKxVohT2VEFd8yIn9H7Hc=";
  };

  format = "pyproject";
  propagatedBuildInputs = [ poetry-core i3ipc ];

  doCheck = false;

  meta = with lib; {
    description = "Balance windows and workspaces in i3wm";
    homepage = "https://github.com/atreyasha/i3-balance-workspace";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
