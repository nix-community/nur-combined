import asyncio
from playwright.async_api import Playwright, async_playwright, expect
import pyotp
import sys

file_server_domain = "files.test.example.com"
kanidm_domain = "kanidm.test.example.com"
password = "thisisdefinitelyasecurepassword"

reset_token = sys.argv[1]


async def run(playwright: Playwright) -> None:
    print("Launching playwright headless browser")
    browser = await playwright.chromium.launch(
        headless=True,
        slow_mo=1000,  # in ms
        proxy={"server": "http://localhost:8888"},
    )
    context = await browser.new_context(
        ignore_https_errors=True,
    )
    page = await context.new_page()
    print("Browsing to reset page")
    await page.goto(f"https://{kanidm_domain}/ui/reset?token={reset_token}")
    await asyncio.sleep(0.1)
    await page.get_by_role("button", name="Add Password").click()
    await page.get_by_role("textbox", name="Enter New Password").fill(password)
    await page.get_by_role("textbox", name="Repeat Password").fill(password)
    await asyncio.sleep(0.1)
    await page.get_by_role("button", name="Submit").click()
    await expect(
        page.get_by_text(
            "Multi-Factor Authentication is required for your account. Delete the generated"
        )
    ).to_be_visible()
    await asyncio.sleep(0.1)
    await page.get_by_role("button", name="Add TOTP").click()
    # grab otp url
    code = page.get_by_role("code")
    await expect(code).to_contain_text("otpauth://totp/")
    otp_uri = (await code.text_content()).strip()
    totp = pyotp.parse_uri(otp_uri)
    await page.get_by_role("textbox", name="Enter a name for your TOTP").fill(
        "otp for test"
    )
    await page.get_by_role("textbox", name="Enter a TOTP code to confirm").fill(
        totp.now()
    )
    await asyncio.sleep(0.1)
    await page.get_by_role("button", name="Add").click()
    save_btn = page.get_by_role("button", name="Save Changes")
    await expect(save_btn).to_be_visible()
    await asyncio.sleep(0.1)
    await save_btn.click()
    await expect(page.get_by_role("textbox", name="Username")).to_be_visible()
    print("New password+otp saved")

    await page.goto(f"https://{file_server_domain}/awesomefile.txt")
    await page.get_by_role("textbox", name="Username").fill("testperson")
    await page.get_by_role("button", name="Begin").click()
    await page.get_by_role("textbox", name="Two-factor authentication code").fill(
        totp.now()
    )
    await page.get_by_role("button", name="Submit").click()
    await page.get_by_role("textbox", name="Password").fill(
        "thisisdefinitelyasecurepassword"
    )
    await page.get_by_role("button", name="Submit").click()
    await page.get_by_role("button", name="Proceed").click()
    await expect(page.locator("pre")).to_contain_text(
        "This is the contents of the awesome file"
    )

    # ---------------------
    await context.close()
    await browser.close()


async def main() -> None:
    async with async_playwright() as playwright:
        await run(playwright)


asyncio.run(main())
