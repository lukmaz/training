#!/bin/bash
set -e

set -x
# runs benchmark and reports time to convergence
# to use the script:
#   run_and_time.sh <random seed 1-5>

THRESHOLD=1.0
BASEDIR='/data/cache'
DATASET=${DATASET:-ml-20m}

# Get command line seed
seed=${1:-1}

# Get the multipliers for expanding the dataset
USER_MUL=${USER_MUL:-16}
ITEM_MUL=${ITEM_MUL:-32}

ALIAS_TABLE=${ALIAS_TABLE:-'_cache'}

BS=${BS:-65536}
LR=${LR:-0.0002}
beta1=${beta1:-0.9}
beta2=${beta2:-0.999}

DATASET_DIR=${BASEDIR}/${DATASET}x${USER_MUL}x${ITEM_MUL}${ALIAS_TABLE}

if [ -d ${DATASET_DIR} ]
then
    ls ${DATASET_DIR}
    # start timing
    start=$(date +%s)
    start_fmt=$(date +%Y-%m-%d\ %r)
    echo "STARTING TIMING RUN AT $start_fmt"

	python ncf.py ${DATASET_DIR} \
        -l ${LR} \
        -b ${BS} \
        --beta1 ${beta1} \
        --beta2 ${beta2} \
        --layers 256 256 128 64 \
        -f 64 \
		--seed $seed \
        --threshold $THRESHOLD \
        --user_scaling ${USER_MUL} \
        --item_scaling ${ITEM_MUL} \
        --cpu_dataloader

	# end timing
	end=$(date +%s)
	end_fmt=$(date +%Y-%m-%d\ %r)
	echo "ENDING TIMING RUN AT $end_fmt"


	# report result
	result=$(( $end - $start ))
	result_name="recommendation"


	echo "RESULT,$result_name,$seed,$result,$USER,$start_fmt"
else
	echo "Directory ${DATASET_DIR} does not exist"
fi

set +x
