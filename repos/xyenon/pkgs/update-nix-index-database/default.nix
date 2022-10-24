{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "update-nix-index-database";
  version = "unstable-2022-10-24";

  src = ./src;

  postPatch = ''
    patchShebangs --host $src/update-nix-index-database.sh
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src/update-nix-index-database.sh $out/bin/update-nix-index-database
    chmod +x $out/bin/update-nix-index-database
  '';

  meta = with lib; {
    description = "Weekly updated nix-index database";
    homepage = "https://github.com/Mic92/nix-index-database";
    license = licenses.mit;
    platforms = platforms.x86_64;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "update-nix-index-database";
  };
}
