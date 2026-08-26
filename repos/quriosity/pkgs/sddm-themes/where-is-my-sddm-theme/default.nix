{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "where-is-my-sddm-theme";
  version = "2fddf8";

  src = fetchFromGitHub {
    owner = "stepanzubkov";
    repo = "where-is-my-sddm-theme";
    rev = "2fddf85ec80ff02a8e20fdcba51a30b436d76e6c";
    hash = "sha256-SNCgpgPyJf9tKE6UyvmEpSJbIfLmAmPazTF85j0W7a0=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sddm/themes/wims-theme
    cp -r where_is_my_sddm_theme/Main.qml where_is_my_sddm_theme/UsersChoose.qml where_is_my_sddm_theme/SessionsChoose.qml where_is_my_sddm_theme/metadata.desktop where_is_my_sddm_theme/theme.conf where_is_my_sddm_theme/example_configs \
      $out/share/sddm/themes/wims-theme/
  '';

  meta = with lib; {
    description = "The most minimalistic and highly customizable SDDM theme";
    homepage = "https://github.com/stepanzubkov/where-is-my-sddm-theme";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
