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
    sha256 = "0xzc8xzj4cnz2m26akr1bb2lm292b8dbvyhkw82wc0ijq1hr0nzk";
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
