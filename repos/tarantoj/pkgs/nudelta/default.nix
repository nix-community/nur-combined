let
  pname = "nudelta";
  version = "0.7.4";
in
  {
    pkgs,
    lib,
  }:
    pkgs.appimageTools.wrapType2 {
      inherit pname version;
      src = pkgs.fetchurl {
        url = "https://github.com/donn/${pname}/releases/download/${version}/nudelta-amd64.AppImage";
        sha256 = "sha256:130rlaczzbzidjrlqy3czsc829bb16hfi154088qaj7r4la6cblj";
      };

      meta = with pkgs.lib; {
        description = "An open-source alternative to the NuPhy Console created by reverse-engineering the keyboards' USB protocol.";
        license = licenses.gpl3Only;
        homepage = "https://github.com/donn/nudelta";
        changelog = "https://github.com/donn/nudelta/blob/main/Changelog.md";
        platforms = lib.intersectLists platforms.x86_64 platforms.linux;
        mainProgram = "nudelta";
      };
    }
