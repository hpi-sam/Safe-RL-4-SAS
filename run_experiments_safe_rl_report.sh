MODEL='a2c' # 'dqn' 'ppo' 'trpo' 'a2c'
SHIELD_DISTANCE=0
SPEED_LIMIT=100 # '30' '50' '80' '100' '130'
ROUTE_FILE='./nets/simple_intersection/evaluation_routes/simple_intersection_[1_1_1].rou.xml'

speed_limit=50
shield_distance=0
for model in 'dqn' 'ppo' 'trpo' 'a2c'; do
  for (( index = 30; index < 300; index++ )); do
    python /Users/finn/Code/Safe-RL-4-SAS/experiments/evaluate_model_safe_rl_report.py $model $shield_distance $speed_limit "$ROUTE_FILE" $index
  done
done

shield_distance=0
for model in 'trpo' 'a2c'; do
  for speed_limit in '30' '50' '80' '100' '130'; do
    for (( index = 30; index < 300; index++ )); do
      python /Users/finn/Code/Safe-RL-4-SAS/experiments/evaluate_model_safe_rl_report.py $model $shield_distance $speed_limit "$ROUTE_FILE" $index
    done
  done
done

model='a2c'
speed_limit='50'
for shield_distance in '1' '5' '10' '20' '50' '100'; do
  for (( index = 30; index < 300; index++ )); do
    python /Users/finn/Code/Safe-RL-4-SAS/experiments/evaluate_model_safe_rl_report.py $model $shield_distance $speed_limit "$ROUTE_FILE" $index
  done
done

#for (( index = 0; index < 1000; index++ )); do
#  python ./experiments/evaluate_model_load_balanced.py $MODEL $SHIELD_DISTANCE $SPEED_LIMIT "$ROUTE_FILE" $index
#done

#for route_file in ./nets/simple_intersection/evaluation_routes/*.rou.xml ; do
#  for (( index = 0; index < 2; index++ )); do
#    python ./experiments/evaluate_model_load_balanced.py $MODEL $SHIELD_DISTANCE $SPEED_LIMIT "$route_file" $index
#  done
#done



