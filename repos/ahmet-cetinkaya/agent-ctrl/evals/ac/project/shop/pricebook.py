from decimal import Decimal

from shop.money import round_money


class PriceBook:
    """Current prices per SKU: base price minus the SKU's discount rate."""

    def __init__(self, base_prices):
        self._base = {sku: Decimal(price) for sku, price in base_prices.items()}
        self._discounts = {}
        self._cache = {}

    def set_base(self, sku, price):
        self._base[sku] = Decimal(price)
        self._cache.pop(sku, None)

    def bulk_update(self, prices):
        for sku, price in prices.items():
            self.set_base(sku, price)

    def set_discount(self, sku, rate):
        self._discounts[sku] = Decimal(rate)
        self._cache.pop(sku, None)

    def price(self, sku):
        if sku not in self._cache:
            discount = self._discounts.get(sku, Decimal(0))
            self._cache[sku] = round_money(self._base[sku] * (1 - discount))
        return self._cache[sku]
