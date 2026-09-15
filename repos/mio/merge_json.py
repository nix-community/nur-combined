import json

with open("old.json") as f:
    old = json.load(f)

with open("pkgs/jetbrains_idea-oss/idea_maven_artefacts.json") as f:
    new = json.load(f)

# Filter out 52 from new
new = [x for x in new if "2.4.20-ij262-52" not in x["url"]]

# Add 34 from old
for x in old:
    if "2.4.20-ij262-34" in x["url"]:
        new.append(x)

# Sort
new.sort(key=lambda x: x["url"])

with open("pkgs/jetbrains_idea-oss/idea_maven_artefacts.json", "w") as f:
    json.dump(new, f, indent=4)
