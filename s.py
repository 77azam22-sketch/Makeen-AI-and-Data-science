



largest = None

inputStr = input("Enter a number (press Enter to stop): ")

while inputStr != "":
    value = float(inputStr)

    if largest is None or value > largest:
        largest = value

    
    inputStr = input("Enter a number (press Enter to stop): ")

if largest is None:
    print("No numbers were entered.")
else:
    print("The largest number is:", largest)
