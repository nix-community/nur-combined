from shop.money import apply_tax, parse_money


def invoice_total(lines, tax_rate):
    """Sum taxed line amounts; each line is {'amount': '<text>'}."""
    return sum((apply_tax(parse_money(line["amount"]), tax_rate) for line in lines), start=0)
