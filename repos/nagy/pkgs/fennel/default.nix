{ lib, lua53Packages, fetchurl, installShellFiles }:

with lua53Packages;
buildLuarocksPackage rec {
  pname = "fennel";
  version = "0.9.1-1";

  src = fetchurl {
    url = "mirror://luarocks/fennel-${version}.src.rock";
    sha256 = "11sv6cmb4l7ain3p0wqf23n0966n2xls42ynigb7mdbdjy89afa0";
  };

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [ lua ];

  outputs = [ "out" "man" ];

  postInstall = ''
    installManPage fennel.1
  '';

  meta = with lib; {
    description = "A lisp that compiles to Lua";
    homepage = "https://fennel-lang.org/";
    license = licenses.mit;
  };
}
