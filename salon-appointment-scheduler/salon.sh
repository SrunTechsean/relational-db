#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display the available services
echo -e "\n~~~~~~~~~~~~~~~ TS SALON ~~~~~~~~~~~~~~~\n"
echo "Welcome to TS Salon! How can I help you?"

AVAILABLE_SERVICES=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")

echo "$AVAILABLE_SERVICES"

# Ask for a valid service
while true
do
  echo -e "\nEnter the service_id of the service you'd like:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -n $SERVICE_NAME ]]
  then
    break
  else
    echo -e "\nI could not find that service. What would you like today?"
    echo "$AVAILABLE_SERVICES"
  fi
done

# Get the customer's phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Look up the customer by phone number
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If the customer is new, collect their name and insert them
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Ask for the appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Save the appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm the appointment
if [[ -n $CUSTOMER_ID && -n $SERVICE_NAME && -n $SERVICE_TIME ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi