{ re3, lib, fetchFromGitHub }:

re3.overrideAttrs (oldAttrs: rec {
  pname = "revc";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "GTAmodding";
    repo = "re3";
    # miami branch
    rev = "3988fec6e72a7ac7172cc5b709bd84ca963c17ba";
    sha256 = "0156r80qvdv5rscwhz6wdll0njk4z6n0axhfzxgx2z3aqhn5h9kn";
    fetchSubmodules = true;
  };

  installPhase = ''
    install -Dm755 ../bin/linux-amd64-librw_gl3_glfw-oal/Release/reVC $out/bin/revc
    mkdir -p $out/share/games/revc
    cp -r ../gamefiles $out/share/games/revc
  '';
  meta = with lib; {
    description = "GTA Vice City engine";
    license = licenses.unfree;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
})
