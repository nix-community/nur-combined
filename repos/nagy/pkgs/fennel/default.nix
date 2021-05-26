{ lib, lua53Packages, fetchurl, installShellFiles }:

with lua53Packages;
buildLuarocksPackage rec {
  pname = "fennel";
  version = "0.9.2-1";

  src = fetchurl {
    url = "mirror://luarocks/fennel-${version}.src.rock";
    sha256 = "1ki1cm33f2vlgyargs1p30ixppvvzl0fznnyhwvr6x70g91damd9";
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
