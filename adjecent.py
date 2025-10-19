
previous = input("Enter a number (press Enter to stop): ")


while previous != "":
    current = input("Enter a number (press Enter to stop): ")
    
    if current == "":
        break
    
    if previous == current:
        print("Found adjacent equal numbers:", previous, "and", current)
    
    previous = current
