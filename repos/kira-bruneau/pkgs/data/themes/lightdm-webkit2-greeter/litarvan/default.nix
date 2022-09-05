{ lib, fetchzip }:

(fetchzip {
  url = "https://github.com/Litarvan/lightdm-webkit-theme-litarvan/releases/download/v3.2.0/lightdm-webkit-theme-litarvan-3.2.0.tar.gz";
  stripRoot = false;
  sha256 = "sha256-TfNhwM8xVAEWQa5bBdv8WlmE3Q9AkpworEDDGsLbR4I=";
}) // {
  meta = with lib; {
    description = "Litarvan's LightDM HTML Theme";
    homepage = "https://github.com/Litarvan/lightdm-webkit-theme-litarvan";
    license = licenses.bsd3;
    maintainers = with maintainers; [ kira-bruneau ];
    platforms = platforms.all;
  };
}
