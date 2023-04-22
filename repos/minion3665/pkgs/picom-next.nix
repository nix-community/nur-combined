{ picom, lib, fetchFromGitHub }:

picom.overrideAttrs (oldAttrs: rec {
  pname = "picom-next";
  version = "unstable-2022-11-05";
  src = fetchFromGitHub {
    owner = "yshui";
    repo = "picom";
    rev = "d59ec6a34ae7435e8d01d85412a5dfaf18f90f68";
    sha256 = "sha256-CvSxeonV0pKvIyKQplnNFgDDlekN6LKGbhdwmOmwJTo=";
  };
  meta.maintainers = with lib.maintainers; oldAttrs.meta.maintainers ++ [ GKasparov minion3665 ];
})
