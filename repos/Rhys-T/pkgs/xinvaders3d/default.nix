{stdenv, lib, fetchurl, xorg, maintainers}: stdenv.mkDerivation rec {
    pname = "xinvaders3d";
    version = "1.9.0";
    src = fetchurl {
        url = "https://github.com/JoesCat/${pname}/releases/download/${version}/${pname}-dist-${version}.tar.gz";
        hash = "sha256-L7QeFyWZSkGCP3ZmgFAPtzWUEOkHITava2iIpIYkxcM=";
    };
    buildInputs = with xorg; [libX11 xtrans];
    meta = {
        description = "3D Vector Graphics Space Invaders clone for X11";
        longDescription = ''
            XInvaders 3D is a vector-graphics Space Invaders clone for the X Window System.
            
            You are a lone star fighter facing endless waves of space aliens. Your sole objective is to shoot down as many aliens as you can. All objects are represented with 3D vector graphics, allowing the aliens to grow in size as they move closer to you.
        '';
        homepage = "https://github.com/JoesCat/xinvaders3d";
        license = lib.licenses.gpl2Plus;
        mainProgram = "xinvaders3d";
        maintainers = [maintainers.Rhys-T];
    };
}
