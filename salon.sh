#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {

  if [[ $1 ]]
    then
    echo -e "\n$1\n"
  fi

  SERVICES
}

#Book Appointment
SERVICES() {
  echo -e "\nThis is our services:\n"

  #Available Services
  AVAILABLE_SERVICES=$($PSQL "select service_id,name from services order by service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
   read SERVICE_ID_SELECTED
  
  #get service name
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED ")

  #is service on the list?
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU

    else

 #ask for the phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #check is there customer name
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        #insert customer name and phone number
        INSERT_CUSTOMER_DATA=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    
    #ask for time
    echo -e "\nWhat time for your appointment.?"
    read SERVICE_TIME

    #get customer id
    CUSTOMER_ID=$($PSQL "select customer_id  from customers where phone = '$CUSTOMER_PHONE'")

    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values( $CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")


  EXIT "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  fi
}

#Exit
EXIT() {
  echo $1
}

MAIN_MENU
