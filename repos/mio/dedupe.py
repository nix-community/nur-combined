import json

with open("pkgs/jetbrains_idea-oss/idea_maven_artefacts.json") as f:
    data = json.load(f)

seen = set()
new_data = []
for x in data:
    if x["url"] not in seen:
        seen.add(x["url"])
        new_data.append(x)

with open("pkgs/jetbrains_idea-oss/idea_maven_artefacts.json", "w") as f:
    json.dump(new_data, f, indent=4)
