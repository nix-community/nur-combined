#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodejs

set -eux
set -o pipefail

cat <<EOF |
'use strict';
const fs = require('fs');

var userPrefs = {};
function user_pref(key, value) {
    userPrefs[key] = value;
}
require('./user.js');
let data = JSON.stringify(userPrefs, null, 2);
fs.writeFileSync('settings.json', data);
EOF
node
