import unittest

from shop.catalog import add_tag, new_item


class Hidden(unittest.TestCase):
    def test_items_do_not_share_tags(self):
        first, second = new_item("a"), new_item("b")
        add_tag(first, "sale")
        self.assertEqual(second["tags"], [])

    def test_caller_list_not_aliased(self):
        given = ["x"]
        add_tag(new_item("c", given), "y")
        self.assertEqual(given, ["x"])
