from decimal import ROUND_HALF_UP, Decimal

CENT = Decimal("0.01")


def parse_money(text):
    """Parse an amount such as '1,234.50' into a Decimal."""
    return Decimal(text.replace(",", "").strip())


def round_money(amount):
    """Round to whole cents, halves away from zero."""
    return Decimal(amount).quantize(CENT, rounding=ROUND_HALF_UP)


def apply_tax(amount, rate):
    return round_money(Decimal(amount) * (1 + Decimal(rate)))
