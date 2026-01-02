import asyncio
from playwright.async_api import Playwright, async_playwright, expect
import pyotp
from typing import TYPE_CHECKING
import os
import json

DATA_JSON = """
@data@
"""

if TYPE_CHECKING:
    from hints import *  # type: ignore


DATA = json.loads(DATA_JSON)
kanidm_password: str = DATA["kanidmPassword"]
playwright_driver_browsers: str = DATA["playwrightDriverBrowsers"]
os.environ["PLAYWRIGHT_BROWSERS_PATH"] = playwright_driver_browsers

start_all()

for machine in [client, fileServer, kanidm]:
    machine.wait_for_unit("multi-user.target")
# wait for every relevant service so that if they fail the test will fail earlier
fileServer.wait_for_unit("caddy.service")
fileServer.wait_for_unit("file_server-oauth2-proxy.service")
client.wait_for_unit("squid.service")
kanidm.wait_for_unit("kanidm.service")
client.forward_port(8888, 8888)

kanidm_domain = "kanidm.test.example.com"
file_server_domain = "files.test.example.com"
password = "thisisdefinitelyasecurepassword"

resp = client.succeed(
    f"curl -u test:test --fail https://{file_server_domain}/awesomefile.txt"
)
assert resp.strip() == "This is the contents of the awesome file"
resp = client.succeed(
    f"curl -u test:test2 --fail https://{file_server_domain}/awesomefile.txt"
)
assert resp.strip() == "This is the contents of the awesome file"
client.fail(f"curl -u test:badpass --fail https://{file_server_domain}/awesomefile.txt")
client.fail(
    f"curl -u baduser:badpass --fail https://{file_server_domain}/awesomefile.txt"
)

reset_token = client.succeed("kanidmGetResetToken").strip()


def logit(msg: str):
    print(msg)


async def run(playwright: Playwright) -> None:
    logit("Launching playwright headless browser")
    browser = await playwright.chromium.launch(
        headless=True,
        slow_mo=1000,  # in ms
        proxy={"server": "http://localhost:8888"},
    )
    context = await browser.new_context(
        ignore_https_errors=True,
    )
    page = await context.new_page()
    logit("Browsing to reset page")
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
    logit("New password+otp saved")

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
# res = client.succeed("doTest")
# print(f"{res=}")
# client.succeed(f"KANIDM_PASSWORD={kanidm_password} kanidm login -D idm_admin")
# res = client.succeed("kanidm person credential create-reset-token testperson --output json")
# print(f"{res=}")
