{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "laboratory-by-mozilla";
  url = "https://addons.mozilla.org/firefox/downloads/file/3716439/laboratory_content_security_policy_csp_toolkit-3.0.8-fx.xpi";
  sha256 = "sha256-t1sJASWHaG34ev72cb+fDiepgS6UeB1CUDKjbzilq6I=";

  # meta = with lib; {
  #   homepage = "https://github.com/april/laboratory/";
  #   description = "An addon that helps you generate a proper Content Security Policy (CSP) header for your website";
  #   longDescription = ''
  #     Laboratory is an extention that helps you generate a proper Content
  #     Security Policy (CSP) header for your website. Simply start recording,
  #     browse your site, and enjoy the CSP header that it produces.
  #     Because good website security shouldn't only be available to mad
  #     scientists!
  #   '';
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ jk ];
  # };
}
