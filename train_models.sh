# python file.py model filename shield_length
# SPEED_LIMITS=("30" "50" "80" "100" "130")
STARTING_TIME=$(date)
echo "START" >> info.log
echo "$STARTING_TIME" >> info.log
SPEED_LIMITS="30 50 80 100 130"
for SPEED_LIMIT in $SPEED_LIMITS
  do
    CURRENT_TIME=$(date)
    echo "$SPEED_LIMIT" >> info.log
    echo "$CURRENT_TIME" >> info.log

    python experiments/a2c_simple_intersection.py $SPEED_LIMIT
    python experiments/dqn_simple_intersection.py $SPEED_LIMIT
    python experiments/ppo_simple_intersection.py $SPEED_LIMIT
    python experiments/trpo_simple_intersection.py $SPEED_LIMIT
  done

ENDING_TIME=$(date)
echo "START" >> info.log
echo "$ENDING_TIME" >> info.log
