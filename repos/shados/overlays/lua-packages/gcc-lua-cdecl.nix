{
  lib,
  buildLuaPackage,
  fetchgit,
  pkg-config,
  gcc-lua,
}:
buildLuaPackage rec {
  pname = "gcc-lua-cdecl";
  version = "unstable-2023-08-30";

  src = fetchgit {
    url = "https://git.colberg.org/peter/${pname}.git";
    sha256 = "sha256-uXnPx2rhzPA3eGsgJJD5c1wICj0/MRYWS14X2vz81lA=";
  };

  preBuild = ''
    set -x
  '';

  buildInputs = [
    gcc-lua
  ];

  buildFlags = [
    "GCCLUA=${gcc-lua}${gcc-lua.gccPluginPath}"
  ];

  meta = with lib; {
    description = "C declaration composer for the GNU Compiler Collection";
    homepage = "https://git.colberg.org/peter/gcc-lua-cdecl";
    maintainers = [ maintainers.arobyn ];
    license = licenses.mit;
  };
}
