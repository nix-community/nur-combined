{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "noscript";
  url = "https://addons.mozilla.org/firefox/downloads/file/3778947/noscript_security_suite-11.2.8-an+fx.xpi";
  sha256 = "sha256-R0T52ZrL6d7DVXdl7dkXMnK0aByEJSKPtq9SST+FNGc=";

  # meta = with lib; {
  #   https://github.com/hackademix/noscript/
  #   homepage = "https://noscript.net/";
  #   changelog = "https://noscript.net/changelog/";
  #   description = "An addon to allow JavaScript, Java, Flash and other plugins to be executed only by trusted web sites of your choice";
  #   longDescription = ''
  #     The NoScript Firefox extension provides extra protection for Firefox,
  #     Seamonkey and other mozilla-based browsers: this free, open source
  #     add-on allows JavaScript, Java, Flash and other plugins to be executed
  #     only by trusted web sites of your choice (e.g. your online bank).

  #     NoScript also provides the most powerful anti-XSS and anti-Clickjacking
  #     protection ever available in a browser.

  #     NoScript's unique whitelist based pre-emptive script blocking approach
  #     prevents exploitation of security vulnerabilities (known, such as
  #     Meltdown or Spectre, and even not known yet!) with no loss of
  #     functionality... 
  #   '';
  #   license = licenses.gpl2;
  #   maintainers = with maintainers; [ jk ];
  # };
}
