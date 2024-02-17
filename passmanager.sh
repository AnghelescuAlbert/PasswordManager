#/bin/bash

echo -e "1. Register\n2. Login\n3. Quit"
echo -n "Enter your choice: "
read input
if [ $input -eq 1 ]; then
  if [ -s "masterpass.txt" ]; then
    echo -e "\n[-] User already exists!!\n"
  else
    echo -n "Enter your master password: "
    read -s masterpassword
    echo ""
    echo $masterpassword | sha256 >> masterpass.txt
    chmod 444 masterpass.txt
  fi
elif [ $input -eq 2 ]; then
  if [ -s "masterpass.txt" ]; then
    echo -n "Enter your master password: "
    read -s masterpassword
    echo ""
    hashedpass=$(cat masterpass.txt)
    if [ "$(echo $hashedpass)" == "$(echo "$masterpassword" | sha256)" ]; then
      if [ ! -f secretfile.txt ]; then
        touch secretfile.txt
      fi
      echo -e "\n[+] Login Successful!!!\n"
      encpass=$(echo "$masterpassword" | base64)
      while true; do
      echo -e "\n1. Add Password\n2. Remove password\n3. Get Password\n4. View saved websites\n5. Quit\n"
      echo -n "Enter your choice: "
      read choice
      if [ $choice -eq 1 ]; then
        echo -n "Enter website: "
        read website
        if [[ -n $(grep $website secretfile.txt) ]]; then
          echo -e "\n [-] Website already exist!!\n" 
        else
          echo -n "Enter password: "
          read -s password
          echo ""
          encryptedpassword=$(echo -n $password | openssl enc -e -aes-256-cbc -pass pass:$encpass -base64 2>/dev/null)
          encryptedpassword=$(echo $encryptedpassword | sed "s/\n//g" | sed "s/ //g")
          echo "$website:$encryptedpassword" >> secretfile.txt
          echo -e "\n[+] Password saved successfull!!\n"
        fi
      elif [ $choice -eq 2 ]; then
        echo -n "Enter website: "
        read website
        if [[ -n $(grep $website secretfile.txt) ]]; then
          sed -i "/$website/d" secretfile.txt
          echo -e "\n[+] Password removed successfull!!\n"
        else
          echo -e "\n[-] Website not found!!\n"
        fi
      elif [ $choice -eq 3 ]; then
        echo -n "Enter website: "
        read website
        if [[ -n $(grep $website secretfile.txt) ]]; then
          foundedPassword=$(grep $website secretfile.txt | awk -F':' '{print $2}')
          decPassword=$(echo -n $foundedPassword | base64 -d | openssl enc -d -aes-256-cbc -pass pass:$encpass 2>/dev/null)
          echo $decPassword | xclip -selection clipboard
          echo -e "\n[+] Password for $website: $decPassword\n[+] Password saved to clipboard"
          exit
        else
          echo -e "\n[-] Website not found!!!\n"
        fi
      elif [ $choice -eq 4 ]; then
        echo -e "\nWebsites you saved...\n"
        grep ":" secretfile.txt | awk -F':' '{print $1}'
      else
        exit
      fi
      done
    else
      echo -e "\n[-] Login failed!!\n"
    fi
  else
    echo -e "\n[-] You have not registered.\n"
  fi
fi
