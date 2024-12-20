#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n"~~~~~ MY SALON ~~~~~"\n"

FIRST_QUESTION=true
SERVICE_ID_SELECTED=0
SERVICE_NAME=""

while [[ -z $SERVICE_NAME ]]
do
  if [[ $FIRST_QUESTION == true ]]
  then
    echo -e "Welcome to My Salon, how can I help you?\n"
    echo "$($PSQL "SELECT CONCAT(service_id, ') ', name) FROM services")"
    FIRST_QUESTION=false
  else
    echo -e "\nI could not find that service. What would you like today?"
    echo "$($PSQL "SELECT CONCAT(service_id, ') ', name) FROM services")"
  fi
  
  read SERVICE_ID_SELECTED

  EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -n $EXISTS ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERTED_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  if [[ $INSERTED_CUSTOMER == "INSERT 0 1" ]]
  then
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERTED_SERVICE=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
if [[ $INSERTED_SERVICE == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
