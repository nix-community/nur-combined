# shellcheck shell=bash
set -e

activation_flag=

while getopts a name; do
    case $name in
    a)
        activation_flag=1
        ;;
    ?)
        exit 2
        ;;
    esac
done

out="/var/lib/chnroutes/rule.nft"
mkdir -p $(dirname "$out")

if [[ -n "$activation_flag" ]]; then
    if [[ ! -f "$out" ]]; then
        cat >$out <<EOF
table ip my_tproxy {
    set set_chnroutes {
        type ipv4_addr;
        flags interval
    }
}
EOF
    fi
    exit 0
fi

ruleUrls=(
    "https://cdn.jsdelivr.net/gh/misakaio/chnroutes2/chnroutes.txt"
    # "https://cdn.jsdelivr.net/gh/felixonmars/chnroutes-alike/chnroutes-alike.txt"
)

input=$(mktemp)
for url in "${ruleUrls[@]}"; do
    curl -L "$url" >>$input
done

cat >$out <<EOF
table ip my_tproxy {
    set set_chnroutes {
        type ipv4_addr;
        flags interval
    }
}
flush set ip my_tproxy set_chnroutes

table ip my_tproxy {
    set set_chnroutes {
        type ipv4_addr;
        flags interval
        elements = {
EOF

sed -e 's/#.*$//; s/\s//g; /^$/d; :a; N; $!ba; s/\n/,/g' "$input" >>$out

cat >>$out <<EOF
        }
    }
}
EOF

rm $input
