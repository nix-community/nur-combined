#!/usr/bin/env python3

import requests
import json
import argparse
import os

whiteListJson = []

parser = argparse.ArgumentParser(
                    prog='whitelist-all-players',
                    description='A small python script, which reads all .dat files in the playerdataDir and generates a whitelist.json in that directory.',
                    epilog='')

parser.add_argument('playerdataDir', default=os.getcwd(), nargs='?', help='the playerdataDir (in the folder of your minecraft server the path ./world/playerdata). This will be enumerated to get a list of player uuids. The default is the current workdin directory.')

args = parser.parse_args()

print("playerdataDir:", args.playerdataDir)
x = os.listdir(args.playerdataDir)

for i in x:
    if i.endswith(".dat"):
        #creating a blank set
        whiteListEntry = {"uuid":"", "name":""}
        #creating UUID string without the .dat extension
        usrUUID = i[:-4]
        print("processing uuid:", usrUUID)

        #adding player UUID to entry
        whiteListEntry["uuid"] = usrUUID

        #taking the dashes out of the UUID to work with the API
        trimmedUUID = usrUUID.replace("-", "")
        #getting API response
        response = requests.get(f"https://api.minecraftservices.com/minecraft/profile/lookup/" + trimmedUUID).json()

        #adding player's current username to entry
        try:
            whiteListEntry["name"] = response["name"]
        except:
            print("uuid has no name...")
            print(response)
            continue
        print("found name:", whiteListEntry["name"])

        #adding entry to master JSON file
        whiteListJson.append(whiteListEntry)

#creating a whitelist.json file
f = open("whitelist.json", 'w')
#converting master json to pretty print and then writing it to the file
f.write(json.dumps(whiteListJson, indent = 2, sort_keys=True))
#closing file
f.close()
