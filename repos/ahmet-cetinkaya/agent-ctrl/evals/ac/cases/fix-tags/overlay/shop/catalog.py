def new_item(name, tags=[]):
    """Create an item that owns its own tag list."""
    return {"name": name, "tags": tags}


def add_tag(item, tag):
    if tag not in item["tags"]:
        item["tags"].append(tag)
    return item
