nixops show a deprecation message at each deployment because hetzner
info is outdated. To fix it:

    cp -a ~/.nixops ~/.nixops.bak

    nixops export --all > all.json

    network=$(cat all.json| jq -r '."cef694f3-081d-11e9-b31f-0242ec186adf".resources.eldiron."hetzner.networkInfo"' | jq -r -c '.networking.interfaces.eth0 = { "ipv4": { "addresses": [ { "address": .networking.interfaces.eth0.ipAddress, "prefixLength": .networking.interfaces.eth0.prefixLength } ] } }')

    cat all.json | jq --arg network "$network" '."cef694f3-081d-11e9-b31f-0242ec186adf".resources.eldiron."hetzner.networkInfo" = $network' > all_new.json

    nixops delete --force -d eldiron

    nixops import < all_new.json

    rm all.json all_new.json

*check that everything works*, then:

    rm -rf ~/.nixops.bak
