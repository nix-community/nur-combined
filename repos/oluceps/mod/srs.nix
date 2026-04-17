{
  flake.modules.nixos.srs = {
    services.srs = {
      enable = true;
      config = ''
        listen              1935;
        max_connections     1000;
        srs_log_tank        console;
        daemon              off;
        pid /run/srs.pid;

        http_api {
            enabled         on;
            listen          1985;
        }
        http_server {
            enabled         on;
            listen          8083;
            dir             ./objs/nginx/html;
        }
        rtc_server {
            enabled on;
            listen 8000; # UDP port
            candidate $CANDIDATE;
        }
        vhost __defaultVhost__ {
            hls {
                enabled         on;
            }
            http_remux {
                enabled     on;
                mount       [vhost]/[app]/[stream].flv;
            }
            rtc {
                enabled     on;
                rtmp_to_rtc off;
                rtc_to_rtmp off;
            }
            play{
                gop_cache_max_frames 2500;
            }
        }
      '';
    };
  };
}
