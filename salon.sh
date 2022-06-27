#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how may I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display the options for services, along with their service_id
  LIST_SERVICES

  # get input from customer on choice
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

  if [[ -z $SERVICE_ID_RESULT ]]
  then
    # send back to list of services
    echo -e "\nI couldn't find that service, please try again\n"
    MAIN_MENU
  else
    # on successful service selection get customer info
    echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get CUSTOMER_NAME
      echo -e "\nLooks like you're a new customer! What's your name?"
      read CUSTOMER_NAME

      # put new customer in the database
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # get name of selected service
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    # get SERVICE_TIME
    echo -e "\nAnd what time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer_id for database entry
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # record appointment to the database
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    # output successful appointment creation
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

LIST_SERVICES() {
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_AVAILABLE" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

MAIN_MENU