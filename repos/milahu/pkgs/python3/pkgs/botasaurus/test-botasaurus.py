# debug log is not helpful

import logging

logging_level = "INFO"
logging_level = "DEBUG"

logging.basicConfig(
    #format='%(asctime)s %(levelname)s %(message)s',
    # also log the logger %(name)s, so we can filter by logger name
    format='%(asctime)s %(name)s %(levelname)s %(message)s',
    level=logging_level,
)

logger = logging.getLogger("test")



# https://github.com/omkarcloud/botasaurus

from botasaurus import *

@browser
def scrape_heading_task(driver: AntiDetectDriver, data):
    # Navigate to the Omkar Cloud website
    driver.get("https://www.omkar.cloud/")
    
    # Retrieve the heading element's text
    heading = driver.text("h1")

    # FIXME heading == None
    print("heading", repr(heading))

    # keep browser open
    #import time; time.sleep(9999)

    # Save the data as a JSON file in output/scrape_heading_task.json
    # "return" would write "null" to the output file
    return {
        "heading": heading
    }
     
if __name__ == "__main__":
    # Initiate the web scraping task
    scrape_heading_task()
