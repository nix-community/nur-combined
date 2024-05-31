{ fetchFromGitHub
, lib
, makeWrapper
, stdenv
, unstableGitUpdater

  # Dependencies
, jre
, python3
}:

stdenv.mkDerivation rec {
  pname = "decompiler-mc";
  version = "0.9-unstable-2024-04-13";

  src = fetchFromGitHub {
    owner = "hube12";
    repo = "DecompilerMC";
    rev = "3a8aa87d01065fbd7fdc8422f19a0fa379740635";
    hash = "sha256-IdKMUX0/cAlUHIpCSaU5pjffjNwgbFxXv07hJRmGpGk=";
  };

  buildInputs = [ makeWrapper python3 ];

  installPhase = ''
    mkdir --parents $out
    cp --recursive $src/lib $out/lib

    install -D main.py $out/bin/${pname}
    substituteInPlace $out/bin/${pname} --replace-fail ./lib $out/lib
    wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath [ jre ]}
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Automated decompilation of Minecraft";
    homepage = "https://github.com/hube12/DecompilerMC";
    license = with lib.licenses; [
      asl20 # Fernflower (vendored)
      bsd3 # SpecialSource (vendored)
      mit # DecompilerMC, CFR (vendored)
    ];
    mainProgram = pname;
  };
}
