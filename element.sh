#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

NOT_FOUND() {
  echo "I could not find that element in the database."
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  
  # check if the input is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
    if [[ $ATOMIC_NUMBER ]]
    then
      # get the rest of the data
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $1")
      TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $1")
      MPC=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $1")
      BPC=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $1")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."
    else
      NOT_FOUND
    fi

  else
    # argument is not a number
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
    NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
    if [[ -z $SYMBOL && -z $NAME ]]
    then
      NOT_FOUND
    else
      # get the rest of the "shared" data
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL' OR name = '$NAME'")
      TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
      ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
      MPC=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
      BPC=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
      if [[ $SYMBOL ]]
      then
        # fetch name again 
        NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$1'")
      else
        # fetch symbols
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$1'")
      fi

      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."

    fi
    
  fi
fi