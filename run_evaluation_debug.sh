# python file.py model filename shield_length
for COUNTER in "0"
do
  for DISTANCE in "0"
  do
    SHIELD_DISTANCE=$((7*DISTANCE))
    SPEED_LIMITS="30 50 80 100 130"
    for SPEED_LIMIT in $SPEED_LIMITS
    do
      python ./experiments/evaluate_model_parameterized.py a2c DEBUG_trpo_"${SPEED_LIMIT}" $SHIELD_DISTANCE $SPEED_LIMIT
    done
  done
done