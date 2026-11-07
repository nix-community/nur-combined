def paginate(items, page, size):
    """Return the 1-based page `page` of `items`, `size` items per page."""
    if page < 1 or size < 1:
        raise ValueError("page and size must be positive")
    start = (page - 1) * size
    return items[start : start + size]


def page_count(total, size):
    return (total + size - 1) // size
