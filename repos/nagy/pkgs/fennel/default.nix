{ stdenv, lua53Packages, fetchurl }:

with lua53Packages;
buildLuarocksPackage rec {
  pname = "fennel";
  version = "0.7.0-1";
  src = fetchurl {
    url = "mirror://luarocks/fennel-${version}.src.rock";
    sha256 = "0kybik5lbli47xnm0cw9b9zlvldpqvgq0l59iicsflmqw30v5x0p";
  };

  propagatedBuildInputs = [ lua ];

  postInstall = ''
    install -D fennel.1 $out/share/man/man1/fennel.1
  '';

  meta = with stdenv.lib; {
    description = "A lisp that compiles to Lua";
    homepage = "https://fennel-lang.org/";
    license = licenses.mit;
  };
}
