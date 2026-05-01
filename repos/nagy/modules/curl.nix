{
  environment.etc.".curlrc".text = ''
    proto-default https
    location
    compressed
    show-error
  '';

  environment.sessionVariables = {
    CURL_HOME = "/etc";
  };
}
