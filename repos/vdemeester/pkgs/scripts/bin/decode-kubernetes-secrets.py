#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 -p python37Packages.pyaml
# -*- coding: utf-8 -*-
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
import yaml
import base64
import sys

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

if len(sys.argv[0]):
    stream = sys.stdin
else:
    stream = open(sys.argv[1])
data = yaml.load(stream, Loader=Loader)
for d in data['data'].items():
    if d[1] and d[1].endswith("="):
        print("Key: " + d[0] + " \nValue: \n" + \
              base64.b64decode(d[1]).decode('utf-8'))
        print("\n")
