import requests
import json
import os
import pprint
import argparse
from pathlib import Path
from scriptipy import *
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel
from datetime import datetime


class CMCStatus(BaseModel):
    timestamp: datetime
    error_code: int
    error_message: Optional[str]
    elapsed: int
    credit_count: int
    notice: Optional[str]
    total_count: int


class ConversionQuote(BaseModel):
    price: Decimal
    # ...
    last_updated: datetime


class CoinData(BaseModel):
    id: int
    name: str
    symbol: str
    slug: str
    num_market_pairs: int
    date_added: datetime
    tags: list[str]
    # ...
    last_updated: datetime
    quote: dict[str, ConversionQuote]


class CMCResponse(BaseModel):
    status: CMCStatus
    data: list[CoinData]


base_currency = "USD"

cryptos = ["BTC", "ETH", "SOL", "XMR"]

parser = argparse.ArgumentParser(prog="get-crypto-rates")
parser.add_argument("-f", "--filename", type=Path, default="cryptocurrencies.units")
parser.add_argument("-d", "--debug", action="store_true")
parser.add_argument("--cmc-data-file", type=Path, default=None)
args = parser.parse_args()

# data_file = Path("cmc-data.json")

if (
    args.cmc_data_file is not None
    and args.cmc_data_file.exists()
    and args.cmc_data_file.read_text().strip() != ""
):
    response_text = args.cmc_data_file.read_text()
else:
    cmc_api_key = os.environ["CMC_API_KEY"]
    res = requests.get(
        url="https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest",
        headers={
            "X-CMC_PRO_API_KEY": cmc_api_key,
            "Accept": "application/json",
        },
        params={
            "start": 1,
            "limit": 500,
            "convert": base_currency,
        },
    )

    res.raise_for_status()
    response_text = res.text
    if args.cmc_data_file is not None:
        with args.cmc_data_file.open("wt") as f:
            f.write(response_text)

response_dict: dict = json.loads(response_text)
response = CMCResponse(**response_dict)
crypto_list = response.data
crypto_by_symbol = {data.symbol: data for data in crypto_list}

static_part = """\
# minumum divisible units AKA atomic units

satoshi  1e-8 BTC
wei      1e-18 ETH
lamport  1e-9 SOL
# monero uses regular SI prefixes and "-nero" https://www.getmonero.org/resources/moneropedia/denominations.html
# so just define nero = monero and this works. The smallest denomination is 1e-12 XMR, a piconero
nero     XMR
"""

units_file = args.filename
with units_file.open("wt") as f:
    date_str = response.status.timestamp.strftime("%Y-%m-%d")
    f.write(
        f"!message Cryptocurrency exchange rates from coinmarketcap.com ({base_currency} base) on {date_str}\n\n"
    )
    f.write(f"# exchange rates\n\n")
    for symbol in cryptos:
        this_currency_data = crypto_by_symbol[symbol]
        if args.debug:
            pprint.pp(this_currency_data)
        price = this_currency_data.quote[base_currency].price
        f.write(f"{symbol}\t{price:<18} {base_currency}\n")
    f.write("\n\n")

    f.write("# add names as aliases of the symbols\n\n")
    for symbol in cryptos:
        this_currency_data = crypto_by_symbol[symbol]
        name = this_currency_data.name.lower()
        f.write(f"{name:<8} {symbol}\n")
    f.write("\n\n")

    f.write(static_part)
