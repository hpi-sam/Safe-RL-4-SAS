# python file.py model filename shield_length
for COUNTER in {0..1}
do
  for DISTANCE in {0..15}
  do
    SHIELD_DISTANCE=$((7*$DISTANCE))
    python ./experiments/evaluate_model_parameterized.py a2c a2c_shield"${SHIELD_DISTANCE}"_"${COUNTER}" $SHIELD_DISTANCE
  done
done