# Custom bash script to update Cloudflare DNS records to point to public IP
{
  curl,
  dig,
  gawk,
  gnused,
  jq,
  lib,
  writeShellScriptBin,
}:
writeShellScriptBin "cloudflare-ddns" ''
  set -e
  set -o pipefail

  PATH="${
    lib.makeBinPath [
      curl
      dig
      gawk
      gnused
      jq
    ]
  }"

  declare -a DOMAINS=( "$@" )

  if (( ''${#DOMAINS[@]} == 0 )); then
    echo "Please provide domains as command line arguments"
    exit 2
  fi

  if [[ -z "$CLOUDFLARE_API_TOKEN" ]]; then
    echo "Env variable CLOUDFLARE_API_TOKEN not set"
    exit 2
  fi

  function update_record() {
    body=$(jq --null-input \
      --arg ip "$3" \
      '{"content": $ip}')
    curl -sS -X PATCH \
      --fail-with-body \
      --output /dev/null \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -d "$body" \
      "https://api.cloudflare.com/client/v4/zones/$1/dns_records/$2"
  }

  function get_zone_records() {
    curl -sS \
      --fail-with-body \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      "https://api.cloudflare.com/client/v4/zones/$1/dns_records?name=$2&type=A,AAAA" | jq -r --arg zone "$1" '.result.[] | [$zone, .id, .type, .name, .content] | @tsv'
  }

  function get_zones() {
    curl -sS \
      --fail-with-body \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      https://api.cloudflare.com/client/v4/zones | jq -r '.result.[].id'
  }

  function get_record_id() {
    # Finds record for given type and domain, and prints "unchanged" if IP matches, and the zone and record ID otherwise
    echo "$1" | awk -v type="$2" -v domain="$3" -v ip="$4" '{ if ( $3 == type && $4 == domain ) { if ($5 == ip) { print "unchanged" } else { print $1"\t"$2 } } }'
  }

  # warning: the IPs are surrounded by quotes, if they exist (e.g., "1.1.1.1"); sed removes them
  NEW_IPV4=$(dig -4 +short +https @one.one.one.one CH TXT whoami.cloudflare | sed 's/"//g') || NEW_IPV4=""
  NEW_IPV6=$(dig -6 +short +https @one.one.one.one CH TXT whoami.cloudflare | sed 's/"//g') || NEW_IPV6=""

  if [[ -n "$NEW_IPV4" ]]; then
    echo "The public IPv4 address of this machine is $NEW_IPV4"
  else
    echo "WARNING: Could not find the public IPv4 address of this machine"
  fi
  if [[ -n "$NEW_IPV6" ]]; then
    echo "The public IPv6 address of this machine is $NEW_IPV6"
  else
    echo "WARNING: Could not find the public IPv6 address of this machine"
  fi

  if [[ -z "$NEW_IPV4" && -z "$NEW_IPV6" ]]; then
    echo "ERROR: No public IP address has been found. Aborting..."
    exit 1
  fi

  readarray -t zones < <(get_zones)

  domains_csv="$(IFS=, ; echo "''${DOMAINS[*]}")"

  records=""
  for zone in "''${zones[@]}"
  do
    records+="$(get_zone_records "$zone" "$domains_csv")"
    records+=$'\n'
  done

  exit_code=0

  for domain in "''${DOMAINS[@]}"
  do
    echo "Handling domain $domain"

    record_id_a=$(get_record_id "$records" "A" "$domain" "$NEW_IPV4")
    record_id_aaaa=$(get_record_id "$records" "AAAA" "$domain" "$NEW_IPV6")
    if [[ -z $record_id_a && -z $record_id_aaaa ]]; then
      echo "ERROR: Cannot find record for domain $domain."
      exit_code=1
    fi

    if [[ "$record_id_a" == "unchanged" ]]; then
      echo "Record of type A for domain $domain is already up-to-date!"
    elif [[ -n "$record_id_a" ]]; then
      zone_id=$(echo "$record_id_a" | awk '{ print $1 }')
      record_id=$(echo "$record_id_a" | awk '{ print $2 }')
      update_record "$zone_id" "$record_id" "$NEW_IPV4"
      echo "Updated record of type A for domain $domain!"
    fi

    if [[ "$record_id_aaaa" == "unchanged" ]]; then
      echo "Record of type AAAA for domain $domain is already up-to-date!"
    elif [[ -n "$record_id_aaaa" ]]; then
      zone_id=$(echo "$record_id_aaaa" | awk '{ print $1 }')
      record_id=$(echo "$record_id_aaaa" | awk '{ print $2 }')
      update_record "$zone_id" "$record_id" "$NEW_IPV6"
      echo "Updated record of type AAAA for domain $domain!"
    fi
  done

  exit $exit_code
''
