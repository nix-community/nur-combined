def load_rows(text):
    """Parse simple comma-separated text with a header line into dicts."""
    lines = text.split("\n")
    header = lines[0].split(",")
    return [dict(zip(header, line.split(","))) for line in lines[1:] if line]


def export_rows(rows, fields):
    out = [",".join(fields)]
    out += [",".join(str(row[field]) for field in fields) for row in rows]
    return "\n".join(out) + "\n"
