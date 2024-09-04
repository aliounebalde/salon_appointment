#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
WELCOME(){
if [[ $1 ]];then
    echo -e "\n$1"
  fi
  echo -e "\n Welcome to ZANDAZ Luxury Salon ZLS\n"
  echo -e "\nHere are our services:"
  SERVICES_LIST=$($PSQL "SELECT * FROM SERVICES")
  echo "$SERVICES_LIST" | while read SERVICE_ID NAME
  do
    #skip the header
    if [[ $SERVICE_ID =~ ^[0-9]+ ]];then
      echo $SERVICE_ID $NAME | sed 's/ |/)/'
    fi
  done
  MAIN_FUNCTION
}
MAIN_FUNCTION(){
  echo -e "\nChoose a Service: "
  read  SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM SERVICES where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]];then
    WELCOME "You must choose a valid service number from the proposed liste"
  else
    echo "Great you choose the following service: $SERVICE_NAME"
    echo "Give your phone number so we can arrange a appointment"
    echo -e "\nCustomer Phone number: " 
    read CUSTOMER_PHONE
  #verify if the customer exist already 
      IS_EXISTING_CUSTOMER=$($PSQL "SELECT name FROM CUSTOMERS where phone='$CUSTOMER_PHONE'")
      #echo $IS_EXISTING_CUSTOMER
      if [[ -z $IS_EXISTING_CUSTOMER ]];then
      #ask the customer so we can add him/her in the database
        echo -e "\nWhat's your name: "
        read  CUSTOMER_NAME
        #Inserting the new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO CUSTOMERS(name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        echo $INSERT_CUSTOMER_RESULT
        if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]; then
          echo -e "\nWelcome for the first time to our salon."
        else
          WELCOME "We encounter a problem for registing you, probably because of duplicated values in our database"
        fi
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM CUSTOMERS WHERE phone='$CUSTOMER_PHONE'")
      fi
      echo -e "\nWhat time do you wanna come: " 
      read SERVICE_TIME 
      #retrieving customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM CUSTOMERS WHERE phone='$CUSTOMER_PHONE'")
      #inserting appointments data
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
      else
        WELCOME "encoutering a problem while making appointment "
      fi
  fi
  
}
WELCOME 