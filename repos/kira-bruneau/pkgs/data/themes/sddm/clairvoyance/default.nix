{ background ? "Assets/Background.jpg"
, autoFocusPassword ? false
, enableHDPI ? false
, lib
, stdenvNoCC
, fetchFromGitHub
, writeText
}:

let
  theme-conf = writeText "theme.conf" ''
    [General]
    background=${background}
    autoFocusPassword=${lib.boolToString autoFocusPassword}
    enableHDPI=${lib.boolToString enableHDPI}
  '';
in
stdenvNoCC.mkDerivation {
  pname = "sddm-theme-clairvoyance";
  version = "unstable-2019-05-30";

  src = fetchFromGitHub {
    owner = "eayus";
    repo = "sddm-theme-clairvoyance";
    rev = "dfc5984ff8f4a0049190da8c6173ba5667904487";
    sha256 = "sha256-AcVQpG6wPkMtAudqyu/iwZ4N6a2bCdfumCmdqE1E548=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/sddm/themes"
    cp -r . "$out/share/sddm/themes/clairvoyance"
    cp ${theme-conf} "$out/share/sddm/themes/clairvoyance/theme.conf"
    runHook postInstall
  '';

  meta = with lib; {
    description = "An SDDM theme";
    homepage = "https://github.com/eayus/sddm-theme-clairvoyance";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.all;
  };
}
