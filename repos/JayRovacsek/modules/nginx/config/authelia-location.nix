{ config, ... }: {
  environment.etc."nginx/modules/authelia/authelia-location.conf" = {
    mode = "0444";
    inherit (config.services.nginx) user;
    inherit (config.services.nginx) group;
    text = ''
      auth_request /authelia/api/verify;
      auth_request_set $target_url $scheme://$http_host$request_uri;
      auth_request_set $user $upstream_http_remote_user;
      auth_request_set $groups $upstream_http_remote_groups;
      auth_request_set $name $upstream_http_remote_name;
      auth_request_set $email $upstream_http_remote_email;
      proxy_set_header Remote-User $user;
      proxy_set_header Remote-Groups $groups;
      proxy_set_header Remote-Name $name;
      proxy_set_header Remote-Email $email;
      error_page 401 =302 https://$http_host/authelia/?rd=$target_url;
    '';
  };
}
