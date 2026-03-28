#get!/usr/bin/python

import requests, json, sys, time

API_TOKEN = "69c655f5c49d7a1612da1c5a0617d786"
UNITS = 'metric'
LANG = 'en'
CITY = "Hsinchu"

def get_icon(code):
    icons = {
        "01d": "",
        "01n": "",
        "02d": "",
        "02n": "",
        "03d": "󰖐",
        "03n": "󰖐",
        "04d": "",
        "04n": "",
        "09d": "",
        "09n": "",
        "10d": "",
        "10n": "",
        "11d": "",
        "11n": "",
        "13d": "󰖘",
        "13n": "󰖘",
        "50d": "",
        "50n": ""
    }

    try:
        return icons[code]
    except KeyError:
        return None


def main():
    response = requests.get(f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_TOKEN}&lang={LANG}&units={UNITS}").json()
    data = {
        "icon": get_icon(response['weather'][0]['icon']),
        "temp": str(round(response['main']['temp'])) + "°",
        "desc": response['weather'][0]['description'].capitalize()
    }
    return data


if __name__ == "__main__":
    try:
        while True:
            try:
                sys.stdout.write(json.dumps(main()) + "\n")
                sys.stdout.flush()
                time.sleep(1800)
            except requests.exceptions.ConnectionError:
                print("Connection error! Retrying...")
                time.sleep(2)

    except KeyboardInterrupt:
        exit(0)
