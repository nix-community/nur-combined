# XXX(2026-01-01): this WORKS.
# give it a single substack URL and it generates a single .epub, in /tmp.
# seems not capable of exporting an entire domain though.
{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule {
  pname = "substack-to-kindle";
  version = "0-unstable-2025-03-22";

  src = fetchFromGitHub {
    owner = "i-tozer";
    repo = "substack-to-kindle";
    rev = "f3e866735fa63605cab2127a1518101d18dd3dc9";
    hash = "sha256-LGINhX5ozzZDH1mSQOo4hGMsRb58d237aUeXzWSohqs=";
  };
  proxyVendor = true;
  vendorHash = "sha256-xz1vMQw9NkwmueB5SlI3NNwuZvb3MRh9Bubqjcs76u0=";

  patches = [
    ./0001-remove-undesired-features-godotenv-send-to-kindle.patch
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A Go application that converts Substack articles to EPUB, AZW3, or MOBI format and sends them to your Kindle device via email";
    longDescription = ''
      ## Converting Web Articles

      Convert and send a Substack or WordPress article to your Kindle:
      ```sh
      go run main.go -url https://example.substack.com/p/article-name
      ```

      Or:
      ```sh
      go run main.go -url https://example.wordpress.com/2023/04/01/article-name
      ```

      Or simply:
      ```sh
      go run main.go https://example.com/article-name

      ## Specifying Output Format
      By default, the application converts content to EPUB format, which is the recommended format for sending to Kindle devices. You can specify a different output format using the -format flag:
      - epub
      - azw3
      - mobi
      ```
    '';
    homepage = "https://github.com/i-tozer/substack-to-kindle";
    mainProgram = "substack-to-kindle";
    # license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
