
numExams = int(input("How many exam grades does each student have? "))

moreGrades = "Y"

while moreGrades == "Y":

    print("Enter the exam grades:")
    total = 0
    for i in range(1, numExams + 1):
        score = int(input("Exam %d: " % i))
        total += score  

    average = total / numExams
    print("The average is %.2f" % average)

    
    moreGrades = input("Enter exam grades for another student (Y/N)? ").upper()
