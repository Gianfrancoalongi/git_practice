#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_cherry_was_picked ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    cat > training.txt <<EOF
1.  run 2 kilometers
2.
3.
4.
5.  do 50 push ups
6.
7.
8.
9.  do 50 sit ups
10.
11.
12.
13. do 50 push ups
14.
15.
16.
17. do 50 sit ups
EOF
    git add training.txt
    git commit -m 'initial instructions'

    # more cardio and less strength
    git checkout -b more_cardio
    TMP=$(mktemp)
    sed 's/^3./3.  run 2 kilometers/g' training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^7./7.  run 2 kilometers/g' training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^11./11. run 2 kilometers/g' training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^15./15. run 2 kilometers/g' training.txt > ${TMP} && mv ${TMP} training.txt
    git commit -a -m 'more running'
    sed 's/50 push ups/10 push ups/g' training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/50 sit ups/10 sit ups/g' training.txt > ${TMP} && mv ${TMP} training.txt
    git commit -a -m 'less strength focus'
    sed 's/^2./2.  10 min recovery/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^4./4.  10 min recovery/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^8./8.  10 min recovery/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^12./12. 10 min recovery/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^16./16. 10 min recovery/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    git commit -a -m '10 min recovery after running'

    git checkout master
    
    # more strength and less cardio
    git checkout -b more_strength
    sed 's/50 push ups/100 push ups/g' training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/50 sit ups/200 sit ups/g' training.txt > ${TMP} && mv ${TMP} training.txt
    git commit -a -m 'more strength'
    sed 's/^3./3.  20 squats with 60 kg backpack/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^7./7.  20 squats with 60 kg backpack/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^11./11. 20 squats with 60 kg backpack/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    sed 's/^15./15. 20 squats with 60 kg backpack/g'  training.txt > ${TMP} && mv ${TMP} training.txt
    git commit -a -m 'more leg strength'

    git checkout master
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Cherry pick commits from the branches 'more_strength' and
'more_cardio' so that the training program on the main
branch contains 2 sets of 100 push ups, 2 sets of 200 sit 
ups and 5 sets of 2 kilometer runs.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 5.3 Distributed Git - Maintaining a Project
  paragraph 'Rebasing and Cherry Picking Workflows'
Git man pages: git help cherry-pick
EOF
}

check_that_cherry_was_picked() {
    pushd ${1} &> /dev/null
    RES="No - you are not done"
    FACIT_BRANCH=$(mktemp)
cat > ${FACIT_BRANCH} <<EOF
* master
  more_cardio
  more_strength
EOF
    FACIT_LOG=$(mktemp)
cat > ${FACIT_LOG} <<EOF
initial instructions
more running
more strength
EOF
    FACIT_TRAINING=$(mktemp)
cat > ${FACIT_TRAINING} <<EOF
1.  run 2 kilometers
2.
3.  run 2 kilometers
4.
5.  do 100 push ups
6.
7.  run 2 kilometers
8.
9.  do 200 sit ups
10.
11. run 2 kilometers
12.
13. do 100 push ups
14.
15. run 2 kilometers
16.
17. do 200 sit ups
EOF
    ACTUAL_BRANCH=$(mktemp)
    git branch &> ${ACTUAL_BRANCH}
    ACTUAL_LOG=$(mktemp)
    git log --format='%s' | sort &> ${ACTUAL_LOG}
    ACTUAL_TRAINING=$(mktemp)
    cat training.txt &> ${ACTUAL_TRAINING}
    
    diff -E -b ${FACIT_BRANCH} ${ACTUAL_BRANCH} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_LOG} ${ACTUAL_LOG} &> /dev/null
    R2=$?
    diff -E -b -B ${FACIT_TRAINING} ${ACTUAL_TRAINING} &> /dev/null
    R3=$?

    if [[ ${R1} == ${R2} && ${R2} == ${R3} && ${R3} == 0 ]]
    then
    	RES="Verified - you are done"
    else
    	RES="No - you are not done"
    fi
    rm -f ${FACIT_BRANCH} \
    	  ${ACTUAL_BRANCH} \
    	  ${FACIT_LOG} \
    	  ${ACTUAL_LOG} \
    	  ${FACIT_TRAINING} \
    	  ${ACTUAL_TRAINING} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
