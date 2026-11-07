import unittest
from decimal import Decimal

from shop.catalog import add_tag, new_item
from shop.csvio import export_rows, load_rows
from shop.invoice import invoice_total
from shop.pagination import page_count, paginate
from shop.pricebook import PriceBook
from shop.report import sales_summary


class PaginationTest(unittest.TestCase):
    def test_second_page(self):
        self.assertEqual(paginate(list(range(10)), 2, 3), [3, 4, 5])

    def test_page_count(self):
        self.assertEqual(page_count(10, 3), 4)


class InvoiceTest(unittest.TestCase):
    def test_total_with_tax(self):
        self.assertEqual(invoice_total([{"amount": "10.00"}, {"amount": "5.00"}], "0.10"), Decimal("16.50"))


class CatalogTest(unittest.TestCase):
    def test_add_tag_once(self):
        item = add_tag(add_tag(new_item("pen"), "office"), "office")
        self.assertEqual(item["tags"], ["office"])


class PriceBookTest(unittest.TestCase):
    def test_discount(self):
        book = PriceBook({"A": "20.00"})
        book.set_discount("A", "0.25")
        self.assertEqual(book.price("A"), Decimal("15.00"))


class CsvTest(unittest.TestCase):
    def test_round_trip(self):
        rows = [{"sku": "A", "amount": "3.00"}]
        self.assertEqual(load_rows(export_rows(rows, ["sku", "amount"])), rows)

    def test_summary(self):
        self.assertEqual(sales_summary("sku,amount\nA,1.00\nB,2.00\n"), (2, Decimal("3.00")))


if __name__ == "__main__":
    unittest.main()
