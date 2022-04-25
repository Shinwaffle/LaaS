"""
This tool will auto login from the guac login page to the shell prompt.
I never tested this.

You will need to install a package for this to work.
Press the window button and type:
    python -m pip install pyautogui

That should install it and then you can proceed with this script. 
To use this script:
    Make sure you're on the "guacamole" login page (the first website when you visit the ip)
    Run it (double click it)
    focus on the login box on the website
    let it do its magic

It may or may not work, I never tested it.
"""
from pyautogui import write,press

from time import sleep

LOGON = 'containerized'

def cool_write():
    write(login, interval=.1)

print('Waiting 6 seconds for you to click the login field...')
sleep(6)
cool_write()
press('tab')
cool_write()
press('enter')

print('Waiting 3 seconds for the black box to appear...')
sleep(3)
cool_write()
press('enter')
sleep(2)
cool_write()
press('enter')

print('You should be in now, goodbye!')
sleep(3)
