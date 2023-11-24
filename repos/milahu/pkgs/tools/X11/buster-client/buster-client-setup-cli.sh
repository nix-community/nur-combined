#! @runtimeShell@

# note: every browser has a different default location for the userdata dir
# ~/.config/google-chrome/
# ~/.config/chromium/
# ...
chromium_user_data_dir="$HOME/.config/chromium"

# buster 2.0.1 from https://www.crx4chrome.com/crx/128986/
chromium_buster_extension_id=mpbjkejclgfgadiemmefgebjfooflfhl

#buster_client="$(dirname "$(dirname "$(readlink -f "$0")")")"/opt/buster/buster-client
buster_client="@busterClientBin@"

output_path=

for arg in "$@"; do
  case "$arg" in
    --user-data-dir=*)
      chromium_user_data_dir="${arg:16}"
      ;;
    --buster-extension-id=*)
      chromium_buster_extension_id="${arg:22}"
      ;;
    --buster-client=*)
      buster_client="${arg:16}"
      ;;
    --output=*)
      output_path="${arg:9}"
      ;;
    --help)
      echo "create org.buster.client.json" >&2
      echo >&2
      echo "usage:" >&2
      echo "  buster-client-setup-cli [options]" >&2
      echo >&2
      echo "options:" >&2
      echo "  --user-data-dir=path           chromium userdata dir" >&2
      echo "                                 default: $chromium_user_data_dir" >&2
      echo "  --buster-extension-id=string   buster chromium extension ID" >&2
      echo "                                 default: $chromium_buster_extension_id" >&2
      echo "  --buster-client=path           buster-client path" >&2
      echo "                                 default: $buster_client" >&2
      echo "  --output=path                  output path" >&2
      echo "                                 default: \$user_data_dir/NativeMessagingHosts/org.buster.client.json" >&2
      echo >&2
      echo "links:" >&2
      echo "  https://github.com/dessant/buster" >&2
      echo "  https://www.crx4chrome.com/extensions/$chromium_buster_extension_id/" >&2
      echo "  https://stackoverflow.com/questions/26053434/how-is-the-chrome-extension-id-of-an-unpacked-extension-generated" >&2
      exit 1
      ;;
    *)
      echo "error: unrecognized argument: $arg" >&2
      exit 1
      ;;
  esac
done

if ! [ -x "$buster_client" ]; then
  echo "error: buster-client is not executable: $buster_client" >&2
  exit 1
fi

# note: we assume the $buster_client path is clean
# so we dont escape it for json
if [ -z "$output_path" ]; then
  output_path="$chromium_user_data_dir/NativeMessagingHosts/org.buster.client.json"
fi
echo "writing $output_path" >&2
mkdir -p "$(dirname "$output_path")"
cat >"$output_path" <<EOF
{
  "name": "org.buster.client",
  "description": "Buster",
  "path": "$buster_client",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$chromium_buster_extension_id/"
  ]
}
EOF
