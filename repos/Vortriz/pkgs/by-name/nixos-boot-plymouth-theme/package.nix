{
    stdenv,
    fetchFromGitHub,
}:
stdenv.mkDerivation {
    pname = "nixos-boot-plymouth-theme";
    version = "1.0";

    src = fetchFromGitHub {
        owner = "daVinci13";
        repo = "nixos_boot_plymouth";
        rev = "939c8b8dadac04b5a0c9e136edfd9063ef18e3f5";
        sha256 = "sha256-6o07ruZRDi3cja5xELEjd8Z9g0CZbo8kaZK7+9zY280=";
    };

    dontBuild = true;

    installPhase = ''
        mkdir -p $out/share/plymouth/themes/nixos
        cp -r src/nixos/* $out/share/plymouth/themes/nixos/
    '';
}
