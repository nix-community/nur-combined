#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.aiohttp python3Packages.aiofiles
import aiofiles
import aiohttp
import asyncio
import pathlib
import re
import sys

PACKAGE_FILE_PATH = pathlib.Path.joinpath(
    pathlib.Path(__file__).parent.resolve(), "package.nix"
)

API_URL = "https://hyp-api.mihoyo.com/hyp/hyp-connect/api/getGamePackages"

API_PARAMS = {
    # China official version
    "launcher_id": "umfgRO5gh5",
}

URL_PATTERN = (
    r"https://autopatchcn.yuanshen.com/client_app/download/pc_zip/.*/ScatteredFiles"
)


async def fetch_game_package_data() -> dict:
    """Fetches the latest game package data from the API asynchronously.

    Returns:
        dict: Parsed JSON response containing game package details.
    """
    async with aiohttp.ClientSession() as session:
        async with session.get(API_URL, params=API_PARAMS, timeout=10) as response:
            response.raise_for_status()
            return await response.json()


async def update_file_content(
    file_path: str, search_pattern: str, replacement_text: str
) -> None:
    """Updates a file by replacing lines matching a pattern with the provided text asynchronously.

    Args:
        file_path (str): Path to the file to be modified.
        search_pattern (str): Regular expression pattern to search for.
        replacement_text (str): Text to replace the matched pattern.
    """

    async with aiofiles.open(file_path, mode="r") as file:
        lines = await file.readlines()

    async with aiofiles.open(file_path, mode="w") as file:
        for line in lines:
            match = re.search(search_pattern, line)
            if match:
                old_value = match.group(0)
                print(f"Replacing:\n  {old_value} ->\n  {replacement_text}")
                line = re.sub(search_pattern, replacement_text, line)
            await file.write(line)


async def main() -> None:
    """Updates the package file with the latest version and decompressed URL asynchronously."""
    if not pathlib.Path(PACKAGE_FILE_PATH).exists():
        print(f"Error: The file {PACKAGE_FILE_PATH} does not exist.")
        sys.exit(1)

    print("Fetching the latest game package data...")
    latest_package_data = (await fetch_game_package_data())["data"]["game_packages"][0][
        "main"
    ]["major"]
    print("Successfully fetched the latest game package data!")

    # Update version
    latest_version = latest_package_data["version"]
    await update_file_content(
        file_path=PACKAGE_FILE_PATH,
        search_pattern=r"version = \".*\";",
        replacement_text=f'version = "{latest_version}";',
    )

    # Update decompressed URL
    latest_decompressed_url = latest_package_data["res_list_url"]
    await update_file_content(
        file_path=PACKAGE_FILE_PATH,
        search_pattern=URL_PATTERN,
        replacement_text=latest_decompressed_url,
    )


if __name__ == "__main__":
    asyncio.run(main())
