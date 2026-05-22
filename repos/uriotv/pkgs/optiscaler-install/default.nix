{
  lib,
  writeShellApplication,
  coreutils,
  curl,
  jq,
  p7zip,
}:

writeShellApplication {
  name = "optiscaler-install";

  runtimeInputs = [
    coreutils
    curl
    jq
    p7zip
  ];

  text = ''
    set -e
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT

    echo "Fetching latest OptiScaler nightly build..."
    JSON=$(curl -sL "https://api.github.com/repos/xXJSONDeruloXx/OptiScaler-Bleeding-Edge/releases?per_page=50")

    LATEST=$(jq -r '[.[] | select(.tag_name | startswith("master-"))] | sort_by(.published_at) | reverse | .[0]' <<< "$JSON")

    if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
      echo "No nightly build found. Falling back to stable release..."
      JSON=$(curl -sL "https://api.github.com/repos/xXJSONDeruloXx/OptiScaler-Bleeding-Edge/releases/latest")
      TAG=$(echo "$JSON" | jq -r '.tag_name')
      DATE=$(echo "$JSON" | jq -r '.published_at')
      echo "Found: $TAG (published: $DATE)"
      OPTI_URL=$(echo "$JSON" | jq -r '.assets[] | select(.name | test("OptiScaler.*\\.7z$"; "i")) | .browser_download_url' | head -1)
    else
      TAG=$(echo "$LATEST" | jq -r '.tag_name')
      DATE=$(echo "$LATEST" | jq -r '.published_at')
      echo "Found: $TAG (published: $DATE)"
      OPTI_URL=$(echo "$LATEST" | jq -r '.assets[] | select(.name | test("OptiScaler.*\\.7z$"; "i")) | .browser_download_url' | head -1)
    fi

    if [ -z "$OPTI_URL" ]; then
      echo "Error: Could not find OptiScaler download URL"
      exit 1
    fi

    echo "Downloading OptiScaler..."
    curl -sL "$OPTI_URL" -o "$TMP/opti.7z"
    7z x "$TMP/opti.7z" -o"$TMP" -y >/dev/null

    cp -r "$TMP/"* . 2>/dev/null || true
    chmod +x ./setup_linux.sh 2>/dev/null || true

    echo ""
    echo "Running official setup script..."
    exec ./setup_linux.sh "$@"
  '';

  meta = with lib; {
    description = "Downloader and launcher for the official OptiScaler Linux setup script";
    homepage = "https://github.com/xXJSONDeruloXx/OptiScaler-Bleeding-Edge";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "optiscaler-install";
  };
}
