{ lib, lua53Packages, fetchurl, installShellFiles }:

with lua53Packages;
buildLuarocksPackage rec {
  pname = "fennel";
  version = "0.10.0";

  src = fetchurl {
    url = "mirror://luarocks/fennel-${version}-1.src.rock";
    sha256 = "0a7ads3qv99v3frfj80g5z684f32219nd22blkgljx9xb9psxfry";
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
    changelog = "https://git.sr.ht/~technomancy/fennel/tree/${version}/item/changelog.md";
  };
}
