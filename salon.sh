#!/bin/bash
# PSQL="psql --username=freecodecamp --dbname=salon --no-align -t -c "
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ SALON PESUT ~~~~~\n"

MAIN_MENU(){
	# -- PRINT MESSAGE
	if [[ $1 ]]; then
		echo -e "\n$1"
	fi 

	# -- SHOW SERVICES (MENU)
	echo "Choose a number:"
	SERVICES=$($PSQL "SELECT service_id, name FROM services")
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done

	# -- CHOOSE MENU
	read SERVICE_ID_SELECTED
	# MENU_AVAILABLE=$($PSQL "")

	# -- IF NOT INPUT A NUMBER
	if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
		MAIN_MENU "You not insert a number"
	else
		SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
		
		# -- IF SERVICE NOT AVAILABLE
		if [[ -z $SERVICE_ID_SELECTED ]]; then
			MAIN_MENU "Services Not Available"
		else
			# -- GET PHONE NUMBER
			echo -e "\nInput your phone number:"
			read CUSTOMER_PHONE

			# -- GET NAME
			CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

			# -- IF NAME NOT AVAILABLE YET
			if [[ -z $CUSTOMER_NAME ]]; then
				echo -e "\nYou are not registered yet\nInput your name:"
				read CUSTOMER_NAME
				INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
			fi

			# -- GET CUSTOMER ID
			CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
			
			# -- GET SERVICE TIME
			echo -e "\nInput Service Time:"
			read SERVICE_TIME

			# -- INSERT APPOINTMENT
			INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES ('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
			
			# -- TASK SUCCESS
			SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
			echo $(echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed -e 's/^ *| *$/g/')
		fi
	fi
}

# ===========================================
# -- MAIN PROGRAM
MAIN_MENU
