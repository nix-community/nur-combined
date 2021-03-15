{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "happy-bonobo-disable-webrtc";
  url = "https://addons.mozilla.org/firefox/downloads/file/3551985/disable_webrtc-1.0.23-an+fx.xpi";
  sha256 = "sha256-sUTzAyoJiMAYUUbfWgNQgYGzsiz9JqP2xNEy4viD5Ps=";

  # meta = with lib; {
  #   homepage = "https://github.com/ChrisAntaki/disable-webrtc-firefox/";
  #   description = "An addon to easily disable WebRTC";
  #   longDescription = ''
  #     WebRTC allows websites to get your actual IP address from behind your
  #     VPN. This addon fixes that issue and makes your VPN more effective by
  #     changing browser-wide settings in Firefox to easily disable WebRTC.
  #   '';
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ jk ];
  # };
}
