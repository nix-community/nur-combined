#!/usr/bin/env python

import sys
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.firefox.launch(headless=True)
    page = browser.new_page()
    page.goto(sys.argv[1], wait_until="networkidle")
    print(page.content())
    browser.close()
