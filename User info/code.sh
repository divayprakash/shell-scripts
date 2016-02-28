#this is a user shell
clear
echo "Hello $USER"
echo "Today is \t "; date
  echo "Number of users logged-in on the system : \t"; who | wc -l
  echo "Calendar"; cal

#USER is a a system variable
#terminal acts as interface to kernel, frontend to shell
