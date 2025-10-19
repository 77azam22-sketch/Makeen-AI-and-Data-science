
balance = 100


correct_pin = "1234"


attempts = 0
while attempts < 3:
    pin = input("Enter your PIN: ")
    if pin == correct_pin:
        print("PIN accepted. Welcome!")
        break
    else:
        attempts += 1
        print("Incorrect PIN.")
else:
    print("Account locked. Try again later.")
    exit()  


while True:
    print("\n--- ATM Menu ---")
    print("1. Check Balance")
    print("2. Deposit Money")
    print("3. Withdraw Money")
    print("4. Exit")
    
    choice = input("Choose an option (1-4): ")
    
    if choice == "1":
        print("Your current balance is:", balance, "OMR")
    elif choice == "2":
        amount = float(input("Enter amount to deposit: "))
        balance += amount
        print("Money deposited. New balance:", balance, "OMR")
    elif choice == "3":
        amount = float(input("Enter amount to withdraw: "))
        if amount <= balance:
            balance -= amount
            print("Withdrawal successful. New balance:", balance, "OMR")
        else:
            print("Insufficient balance")
    elif choice == "4":
        print("Thank you for using the ATM. Goodbye!")
        break
   