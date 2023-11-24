#! @runtimeShell@

# note: every browser has a different default location for the userdata dir
# ~/.config/google-chrome/
# ~/.config/chromium/
# ...
chromium_user_data_dir="$HOME/.config/chromium"

#buster_client="$(dirname "$(dirname "$(readlink -f "$0")")")"/opt/buster/buster-client
buster_client="@busterClientBin@"

for arg in "$@"; do
  case "$arg" in
    --user-data-dir=*)
      chromium_user_data_dir="${arg:16}"
      ;;
    --buster-client=*)
      buster_client="${arg:16}"
      ;;
    --help)
      echo "usage: buster-client-setup-cli [--user-data-dir=/path/to/chromium-userdata] [--buster-client=/path/to/buster-client]" >&2
      echo >&2
      echo "this will create \$user_data_dir/NativeMessagingHosts/org.buster.client.json" >&2
      echo "pointing to $buster_client" >&2
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
output_path="$chromium_user_data_dir/NativeMessagingHosts/org.buster.client.json"
echo "writing $output_path"
cat >"$output_path" <<EOF
{
  "name": "org.buster.client",
  "description": "Buster",
  "path": "$buster_client",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://mpbjkejclgfgadiemmefgebjfooflfhl/"
  ]
}
EOF
