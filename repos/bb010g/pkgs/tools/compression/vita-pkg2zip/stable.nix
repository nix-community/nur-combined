{ stdenv, fetchFromGitHub, fetchpatch, python3 }:

stdenv.mkDerivation {
  pname = "vita-pkg2zip";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "mmozeiko";
    repo = "pkg2zip";
    # rev = "v${version}";
    rev = "v1.8";
    sha256 = "1gsgyl33rwh7vrldvkpazlxw2kbxc7sd6whsklds5vbmn7qrvsvi";
  };

  buildInputs = [ python3 ];

  outputBin = "out";

  patches = [
    # "ignore unnecessary warnings": build with -Wno-format-truncation
    (fetchpatch {
      url = https://github.com/mmozeiko/pkg2zip/commit/bb1b430ada4510375f070f42d5474c7ce24bf5bf.patch;
      sha256 = "0zsk2s4s9pa69kvar025ldc9qhw922y22z9lf7h4ck46hd7l8v3k";
    })
  ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p "''${!outputBin}/bin"
    cp -t "''${!outputBin}/bin/" pkg2zip
    cp rif2zrif.py "''${!outputBin}/bin/rif2zrif"
    cp zrif2rif.py "''${!outputBin}/bin/zrif2rif"

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Decrypt PlayStation Vita pkg files and create zips";
    homepage = https://github.com/mmozeiko/pkg2zip;
    longDescription = ''
      Utility that decrypts PlayStation Vita pkg file and creates zip package.
      Supported pkg files - main application, DLC, patch and PSM files. Also
      supports PSX and PSP pkg files for use with Adrenaline.

      Optionally writes NoNpDrm or NoPsmDrm fake license file from zRIF
      string. You must provide license key.
    '';
    license = with licenses; unlicense;
    maintainers = with maintainers; [ bb010g ];
  };
}
