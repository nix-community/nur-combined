{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "1password-x-password-manager";
  url = "https://addons.mozilla.org/firefox/downloads/file/3784953/1password_password_manager-2.0.2-fx.xpi";
  sha256 = "sha256-0UeBjDvNgIHdJd3+dKBoer48rlYiy/OrLvM0QLGVUjo=";

  # meta = with lib; {
  #   homepage = "https://addons.mozilla.org/en-US/firefox/addon/1password-x-password-manager/";
  #   description = "Password manager addon";
  #   longDescription = ''
  #     The best way to experience 1Password in your browser. Easily sign in to
  #     sites, generate passwords, and store secure information, including logins,
  #     credit cards, notes, and more.
  #   '';
  #   license = licenses.unfree;
  #   maintainers = with maintainers; [ jk ];
  # };
}
