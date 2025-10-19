

count = 0
total = 0

inputStr = input("Enter a number (press Enter to stop): ")

while inputStr != "":
    value = float(inputStr)
    if value < 0:
        count = count + 1
        total = total + value

    inputStr = input("Enter a number (press Enter to stop): ")

print("Count of negative numbers:", count)
print("Total of negative numbers:", total)


