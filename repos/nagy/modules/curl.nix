{
  environment.etc.".curlrc".text = ''
    # proto-default https
    silent
    show-error
    location
    compressed
    connect-timeout 5
    write-out "\n"
    remote-header-name
  '';

  environment.sessionVariables = {
    CURL_HOME = "/etc";
  };
}
