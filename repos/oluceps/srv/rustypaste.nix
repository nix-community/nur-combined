{ ... }:
{
  enable = true;
  settings = {
    config = {
      refresh_rate = "3s";
    };
    landing_page = {
      content_type = "text/plain; charset=utf-8";
      text = ''
                                             |\__/,|   (`\
                                           _.|o o  |_   ) )
                                         -(((---(((--------


        Submit files via HTTP POST here:
            curl -F 'file=@example.txt' <server>
        This will return the URL of the uploaded file nya.
        The server administrator might remove any pastes that they do not personally
        want to host.
        If you are the server administrator and want to change this page, just go
        into your config file and change it! If you change the expiry time, it is
        recommended that you do.
        By default, pastes expire every hour. The server admin may or may not have
        changed this.
        Check out the GitHub repository at https://github.com/orhun/rustypaste
        Command line tool is available  at https://github.com/orhun/rustypaste-cli
      '';
    };
    paste = {
      default_expiry = "128h";
      default_extension = "txt";
      delete_expired_files = {
        enabled = true;
        interval = "1h";
      };
      duplicate_files = true;
      mime_blacklist = [
        "application/x-dosexec"
        "application/java-archive"
        "application/java-vm"
      ];
      mime_override = [
        {
          mime = "image/jpeg";
          regex = "^.*\\.jpg$";
        }
        {
          mime = "image/png";
          regex = "^.*\\.png$";
        }
        {
          mime = "image/svg+xml";
          regex = "^.*\\.svg$";
        }
        {
          mime = "video/webm";
          regex = "^.*\\.webm$";
        }
        {
          mime = "video/x-matroska";
          regex = "^.*\\.mkv$";
        }
        {
          mime = "application/octet-stream";
          regex = "^.*\\.bin$";
        }
        {
          mime = "text/plain";
          regex = "^.*\\.(log|txt|diff|sh|rs|toml)$";
        }
      ];
      random_url = {
        separator = "-";
        type = "petname";
        words = 2;
      };
    };
    server = {
      address = "127.0.0.1:3999";
      expose_list = false;
      expose_version = false;
      handle_spaces = "replace";
      max_content_length = "10MB";
      timeout = "30s";
      upload_path = "./upload";
      url = "https://pb.nyaw.xyz";
    };
  };
}
