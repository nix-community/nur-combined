#!/usr/bin/env -S sd nix shell --really
#!nix-shell -i python3 -p python3Packages.selenium chromedriver chromium

from urllib.request import urlopen, Request
import json
from argparse import ArgumentParser
from pathlib import Path
import time
import base64
import os
from sys import stderr
import email, smtplib, ssl
from shutil import which
from datetime import datetime

from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

parser = ArgumentParser()
parser.add_argument("--user", default=os.getenv("FUSIONSOLAR_USER"))
parser.add_argument("--password", default=os.getenv("FUSIONSOLAR_PASSWORD"))
parser.add_argument('--smtp-user', default=os.getenv("SMTP_USER"))
parser.add_argument('--smtp-passwd', default=os.getenv("SMTP_PASSWD"))
parser.add_argument('--smtp-server', default=os.getenv("SMTP_SERVER"))
parser.add_argument('--smtp-destinations', default=os.getenv("SMTP_DESTINATIONS"))
args = parser.parse_args()

now = datetime.today()

message = MIMEMultipart()
message['From'] = args.smtp_user
message['To'] = args.smtp_destinations.replace(' ', ', ')
message["Subject"] = f"Relatório do dia {str(now).split(' ')[0]} FusionSolar"

service = webdriver.chrome.service.Service(executable_path=which("chromedriver"))
# options = webdriver.ChromeOptions()
# options.add_argument("--headless=new")
# # options.headless = True
driver = webdriver.Chrome(
    # options=options,
    service=service
)

driver.delete_all_cookies()
driver.execute_cdp_cmd('Storage.clearDataForOrigin', {
    "origin": '*',
    "storageTypes": 'all',
})

print('[*] Login', file=stderr)
driver.get("https://intl.fusionsolar.huawei.com/pvmswebsite/login/build/index.html#/LOGIN")
time.sleep(10)
driver.find_element(By.CSS_SELECTOR, "div#username input").send_keys(args.user)
password_input = driver.find_element(By.CSS_SELECTOR, "div#password input")
password_input.send_keys(args.password)
password_input.send_keys(Keys.ENTER)
time.sleep(10)

cooke_close_buttons = driver.find_elements(By.CSS_SELECTOR, "i.cookiePolicy-icon")
for cooke_close_button in cooke_close_buttons:
    print('[*] Fechando diálogo de cookie ocupando espaço', file=stderr)
    cooke_close_button.click()

shitty_modal_candidates = driver.find_elements(By.CSS_SELECTOR, "div.dpdesign-modal.nco-privacy-confirm-modal")
if len(shitty_modal_candidates) > 0:
    print('[*] Encontrada porcaria de modal para autorização de espionagem', file=stderr)
    shitty_modal = shitty_modal_candidates[0]
    shitty_checkbox = shitty_modal.find_element(By.CSS_SELECTOR, "input")
    if shitty_checkbox.is_selected:
        shitty_checkbox.click()
    shitty_button = shitty_modal.find_element(By.CSS_SELECTOR, "button")
    time.sleep(1)

    shitty_button.click()
    time.sleep(10)

stations_data = []
remaining_trys = 5

while len(stations_data) == 0:
    # if 'view/station' in driver.current_url:
    #     print('[*] Redirecionamento corno realizado, pulando etapa', file=stderr)
    #     print('[*] URL do redirecionamento corno: ', driver.current_url)
    #     stations_data.append(dict(
    #         url=driver.current_url,
    #         name="Unica",
    #     ))
    #     break
    print('[*] Homepage', file=stderr)
    driver.get("https://intl.fusionsolar.huawei.com")
    time.sleep(10)
    print('[*] Tentando listar estações', file=stderr)
    stations = driver.find_elements(By.CSS_SELECTOR, "a.nco-home-list-text-ellipsis")
    print('stations', stations, file=stderr)
    if len(stations) == 0:
        print("[*] Zero estações encontradas, tentando de novo", file=stderr)
        remaining_trys -= 1
        print("[*] URL atual: ", driver.current_url, file=stderr)
        if remaining_trys == 0:
            print('[*] Sem estações, desistindo...', file=stderr)
            exit(1)
    for station in stations:
        station_data = dict(
            url=station.get_attribute('href'),
            name=station.text 
        )
        print(station_data, file=stderr)
        stations_data.append(station_data)

email_text = []

email_text.append("Quantidade de energia produzida em cada base")
email_text.append("")


attachments = []
for station in stations_data:
    station_url = station['url']
    station_name = station['name']
    print(f'[*] Chupinhando dados da estação "{station_name}"', file=stderr)
    driver.get(station_url)
    time.sleep(10)
    the_canvas = driver.find_element(By.CSS_SELECTOR, ".nco-single-energy-body canvas")
    canvas_b64 = driver.execute_script("return arguments[0].toDataURL('image/png').substring(21);", the_canvas)
    amount_produced = float(driver.find_element(By.CSS_SELECTOR, "span.value").text.replace(',', '.'))
    email_text.append(f"{station_name}: {amount_produced}kWh")
    print(f'[*] Produzido hoje: {amount_produced}kWh', file=stderr)
    print(f'[*] Salvando dados da estação "{station_name}"', file=stderr)

    image_to_embed = MIMEBase("image", "png")
    image_to_embed.set_payload(base64.b64decode(canvas_b64))
    encoders.encode_base64(image_to_embed)
    image_to_embed.add_header("Content-Disposition", f"attachment; filename= {station_name}.png")
    attachments.append(image_to_embed)

email_text.append("")
email_text.append("Os gráficos de geração estão em anexo.")
email_text.append("")
email_text.append(f"Dados obtidos em: {str(now)}")


message.attach(MIMEText("\n".join(email_text), 'plain'))
for attachment in attachments:
    message.attach(attachment)

context = ssl.create_default_context()
smtp_server, *smtp_port = args.smtp_server.split(":")
if len(smtp_port) == 0:
    smtp_port = 465
else:
    smtp_port = int(smtp_port[0])

print('[*] Enviando emails', file=stderr)

with smtplib.SMTP_SSL(smtp_server, smtp_port, context=context) as server:
    server.login(args.smtp_user, args.smtp_passwd)
    email_txt = message.as_string()
    server.sendmail(args.smtp_user, args.smtp_destinations.split(" "), email_txt)
    
driver.quit()
# token_file = Path.home() / ".fusion-solar"

# token = None
# if token_file.exists():
#     token = token_file.read_text()
# else:
#     request = Request(
#         "https://intl.fusionsolar.huawei.com/thirdData/login",
#         data=json.dumps(dict(
#             userName = args.user,
#             systemCode = args.password
#         )).encode('utf-8'),
#         headers={
#             "accept": "application/json",
#             "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
#         },
#         method='POST'
#     )
#     data = urlopen(request)
#     token = data.getheader("xsrf-token")
#     if token is not None:
#         token_file.write_text(token)
#     print(data)
#     print(data.read())
