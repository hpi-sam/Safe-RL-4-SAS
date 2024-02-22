MODEL='a2c'
SHIELD_DISTANCE=0
SPEED_LIMIT=50
ROUTE_FILE='./nets/simple_intersection/evaluation_routes/simple_intersection_[1_1_1].rou.xml'

for route_file in ./nets/simple_intersection/evaluation_routes/*.rou.xml ; do
  for (( index = 0; index < 2; index++ )); do
    python ./experiments/evaluate_model_load_balanced.py $MODEL $SHIELD_DISTANCE $SPEED_LIMIT "$route_file" $index
  done
done



