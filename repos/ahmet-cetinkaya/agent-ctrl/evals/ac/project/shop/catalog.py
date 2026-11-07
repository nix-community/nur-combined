def new_item(name, tags=None):
    """Create an item that owns its own tag list."""
    return {"name": name, "tags": [] if tags is None else list(tags)}


def add_tag(item, tag):
    if tag not in item["tags"]:
        item["tags"].append(tag)
    return item
