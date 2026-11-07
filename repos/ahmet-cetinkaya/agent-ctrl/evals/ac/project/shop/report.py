from shop.csvio import load_rows
from shop.money import parse_money


def sales_summary(csv_text):
    """Return (row count, total amount) for an uploaded sales CSV."""
    rows = load_rows(csv_text)
    return len(rows), sum((parse_money(row["amount"]) for row in rows), start=0)
