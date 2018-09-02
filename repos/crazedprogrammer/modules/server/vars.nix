rec {
  c3iHome = "/var/lib/c3i";
  grafanaPort = 24003;
  prometheusPort = 24004;
  nodeExporterPort = 24005;
  shittydlPort = 24001;
  shittydlHome = "/var/lib/shittydl";
  theloungePort = 24002;
  theloungeHome = "/var/lib/thelounge";
  theloungeConfig = ''
    module.exports = {
      port: ${toString theloungePort},
      prefetch: true,
      prefetchStorage: true
    }
  '';
  mysqlPort = 24006;
  caddyPort = 443;
  mongodbPort = 24008;
  jamrogueHome = "/var/lib/jamrogue";
  jamroguePort = 24009;
  modmc1Home = "/var/lib/modmc1";
  mediaHome = "/var/lib/media";
  ccfuseHome = "/var/lib/ccfuse";
  ccfusePort = 24010;
  authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5oXykAx/K3hAyZyqxxWNlBXNpUQxRkXMjIBlwIRA9pKbouCE/jN8pXWUiuZQnsnzMwUdd5FAf3gjZGktntiJ5y91fsCIPIWgGd5qBYwhphf9L+xpGjRL21SFf2LVYvl8M/KpDPgv/uELGJoKnHq7KVhOSyOTpPSmWdqneX6RyBS9jHa62pA22eShwauZ0LyUlx1aOyeo+Ds/1eKOS0124P1XSfej/Nl4fO8MZn0M+Q7XJnraicpN9GRkGfBM3uVWe0g/x99fSxLUf9dLdE29oNNyucO4LEvhwpzJ5rKb0Kd96y6aYxtp5/vm9yojlBUvlVKZ122sfmrb8n3zqCo5gUb5phTyXR+iB+w8iY4BoNoZcaXPAbTFbMvcO/bu3CRJfezdeX4yxN2GaO8DjlST86WNA7ib+AYz6IO9BeNWwTtcOJKlBAPOIRavWmudmDKvnY1N/hX9Ib4a7fxFSo0M7QLzuEr58RHcl1UPo2r0ki2dQVBkPY0rl8go1hCIdBu2Lx0YLDjGJbaGWNyf/fO3VmAGX5VWlz+EmBTiFEnxiEhmuL6V6LO3dm0hVXXC/Y2YvrQ8XxXmOBO2brS5w+rq74iyQijQ6Z2+8jfI3tO708n4qjjDGI5kJXpjSp2KNA6XdU9IdUBwtX26d6Evanx5gsdkDJfOIFqV58AWAFgA5nw== xenon"
  ];
}
