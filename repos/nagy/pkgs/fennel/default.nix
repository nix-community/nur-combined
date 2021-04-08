{ lib, lua53Packages, fetchurl, installShellFiles }:

with lua53Packages;
buildLuarocksPackage rec {
  pname = "fennel";
  version = "0.9.0-1";

  src = fetchurl {
    url = "mirror://luarocks/fennel-${version}.src.rock";
    sha256 = "1qidvg8sj9q2i5w2lhgihh9vq7pjmh6k3m7x0hhhqps6qxw268zg";
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
