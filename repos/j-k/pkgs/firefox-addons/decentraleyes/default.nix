{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "decentraleyes";
  url = "https://addons.mozilla.org/firefox/downloads/file/3672658/decentraleyes-2.0.15-an+fx.xpi";
  sha256 = "sha256-JVQGkWhFjME1Hl037pld4ETlFOxyNpgp/wvL8x1Ybd8=";

  # meta = with lib; {
  #   # https://git.synz.io/Synzvato/decentraleyes/
  #   homepage = "https://decentraleyes.org/";
  #   description = "Protects you against tracking through "free", centralized, content delivery";
  #   longDescription = ''
  #     A web browser extension that emulates Content Delivery Networks to
  #     improve your online privacy.
  #     It intercepts traffic, finds supported resources locally, and injects
  #     them into the environment.
  #     All of this happens automatically, so no prior configuration is
  #     required.
  #   '';
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ jk ];
  # };
}
