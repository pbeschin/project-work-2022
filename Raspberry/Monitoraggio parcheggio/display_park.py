# GPIO
import time
from time import sleep
from threading import Thread
import RPi.GPIO as GPIO

pinA = 24
pinB = 18
pinC = 5
pinD = 13
pinE = 26
pinF = 23
pinG = 12
pinDP = 6

D1 = 22
D2 = 27
D3 = 17
D4 = 4

D5 = 19
D6 = 21
D7 = 20
D8 = 16

digits2 = (D5, D6, D7, D8)

# code modified, tweaked and tailored from code by bertwert
# on RPi forum thread topic 91796
GPIO.setmode(GPIO.BCM)

# GPIO ports for the 7seg pins
segments = (pinA, pinB, pinC, pinD, pinE, pinF, pinG, pinDP)

for segment in segments:
    GPIO.setup(segment, GPIO.OUT)
    GPIO.output(segment, 0)

# GPIO ports for the digit 0-3 pins
digits1 = (D1, D2, D3, D4)

for digit in digits1:
    GPIO.setup(digit, GPIO.OUT)
    GPIO.output(digit, 1)

# GPIO ports for the digit 0-3 pins
digits2 = (D5, D6, D7, D8)

for digit in digits2:
    GPIO.setup(digit, GPIO.OUT)
    GPIO.output(digit, 1)

displays = (digits1, digits2)

# displayable characters

disChars = {
    '0': (1, 1, 1, 1, 1, 1, 0, 0),  # 0
    '1': (0, 1, 1, 0, 0, 0, 0, 0),  # 1
    '2': (1, 1, 0, 1, 1, 0, 1, 0),  # 2
    '3': (1, 1, 1, 1, 0, 0, 1, 0),  # 3
    '4': (0, 1, 1, 0, 0, 1, 1, 0),  # 4
    '5': (1, 0, 1, 1, 0, 1, 1, 0),  # 5
    '6': (1, 0, 1, 1, 1, 1, 1, 0),  # 6
    '7': (1, 1, 1, 0, 0, 0, 0, 0),  # 7
    '8': (1, 1, 1, 1, 1, 1, 1, 0),  # 8
    '9': (1, 1, 1, 1, 0, 1, 1, 0),  # 9
    'a': (1, 1, 1, 0, 1, 1, 1, 0),  # A/1
    'b': (0, 0, 1, 1, 1, 1, 1, 0),  # b/2
    'c': (0, 0, 0, 1, 1, 0, 1, 0),  # C/3
    'd': (0, 1, 1, 1, 1, 0, 1, 0),  # d/4
    'e': (1, 0, 0, 1, 1, 1, 1, 0),  # E/5
    'f': (1, 0, 0, 0, 1, 1, 1, 0),  # F/6
    'g': (1, 0, 1, 1, 1, 1, 0, 0),  # G/7
    'h': (0, 1, 1, 0, 1, 1, 1, 0),  # H/8
    'i': (0, 1, 1, 0, 0, 0, 0, 0),  # I/9
    'j': (0, 1, 1, 1, 1, 0, 0, 0),  # J/10
    'l': (0, 0, 0, 1, 1, 1, 0, 0),  # L/11
    'n': (0, 0, 1, 0, 1, 0, 1, 0),  # n/12
    'o': (0, 0, 1, 1, 1, 0, 1, 0),  # o/13
    'p': (1, 1, 0, 0, 1, 1, 1, 0),  # P/14
    'q': (1, 1, 1, 0, 0, 1, 1, 0),  # q/15
    'r': (0, 0, 0, 0, 1, 0, 1, 0),  # r/16
    's': (1, 0, 1, 1, 0, 1, 1, 0),  # S/17   looks like number 5
    't': (0, 0, 0, 1, 1, 1, 1, 0),  # t/18
    'u': (0, 1, 1, 1, 1, 1, 0, 0),  # U/19
    'y': (0, 1, 1, 1, 0, 1, 1, 0),  # y/20
    '.': (0, 0, 0, 0, 0, 0, 0, 1),  # .
    '-': (0, 0, 0, 0, 0, 0, 1, 0),  # dash/negative
    '_': (0, 0, 0, 1, 0, 0, 0, 0),  # underscore
    '[': (1, 0, 0, 1, 1, 1, 0, 0),  # [
    ']': (1, 1, 1, 1, 0, 0, 0, 0),  # ]
    '?': (1, 1, 0, 0, 1, 0, 1, 0),  # ?
    ' ': (0, 0, 0, 0, 0, 0, 0, 0)  # blank
}


def displayPark(level: int, number: int, display=0):
    displayText(f"P{level % 10}{number:02d}", [0, 1, 0, 0], selectedDisplay = display)


def displayText(text, dots=[0, 0, 0, 0], selectedDisplay=1):
    s = text.lower() + ("_" * 4)
    # print(s)
    # char is the current char being displayed
    # dot is if the dot has to be diaplayed or not
    # digit is where the char is being displayed
    for char, dot, digit in zip(s, dots, displays[selectedDisplay]):
        displayDigit(char, dot)
        GPIO.output(digit, 0)
        time.sleep(0.001)
        GPIO.output(digit, 1)
"""
    for digit in range(4):
        displayDigit(s[digit], dots[digit])
        GPIO.output(digits1[digit], 0)
        time.sleep(0.001)
        GPIO.output(digits1[digit], 1)
"""

def displayDigit(char, dot):
    for loop in range(0, 7):
        GPIO.output(segments[loop], disChars[char][loop])
        if (dot):
            GPIO.output(pinDP, 1)
        else:
            GPIO.output(pinDP, 0)


def closeDisplay():
    GPIO.cleanup()


if __name__ == "__main__":
    try:
        while True:
            for level in range(2):
                for occupied in range(51):
                    for _ in range(100):
                        displayPark(level, occupied)
            #displayText("p150", [0, 1, 0, 0])
    finally:
        GPIO.cleanup()
