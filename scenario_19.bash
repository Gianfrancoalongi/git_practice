#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_problem_was_fixed ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d GITPractice_Repo_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    cat > speech.txt <<EOF
Even though large tracts of Europe and many old and famous states 
have fallen or may fall into the grip of the Gestapo and all the 
odious apparatus of Nazi rule, we shall not flag or fail.
EOF
    git add speech.txt
    git commit -m 'first part'
    cat >> speech.txt <<EOF
We shall go on to the end, we shall fight in France, 
we shall fight on the seas and oceans,
EOF
    git commit -a -m 'second part'
    cat >> speech.txt <<EOF
we shall fight with growing confidence and growing strength in the air,
we shall defend our Island whatever the cost may be,
EOF
    git commit -a -m 'third part'
    cat >> speech.txt <<EOF
we shall fight on the beeches, we shall fight on the landing grounds, 
we shall fight in the fields and in the streets,
EOF
    git commit -a -m 'fourth part'
    cat >> speech.txt <<EOF
we shall fight in the hills; We shall never surrender.
EOF
    git commit -a -m 'fifth part'
    cat > /tmp/test.bash <<EOF
#!/bin/bash
grep -q beeches speech.txt
if [[ \$? == 0 ]]
then
   exit 1
else
   exit 0
fi
EOF
    chmod a+x /tmp/test.bash
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Use Git Bisect 'run' to automatically find the bad commit which 
introduces the misspelled word beeches (should have been beaches). 

The script in /tmp/test.bash shall be used to determine the bad 
commit. When the faulty commit is found, edit the commit so that 
the file speech.txt no longer contains an error. 

Do the edit using interactive rebasing.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 6.5 Git Tools - Debugging with Git
Chapter 6.4 Git Tools - Rewriting History
EOF
}

check_that_problem_was_fixed() {
    pushd ${1} &> /dev/null
    git checkout master &> /dev/null
    FACIT_FILE=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE} <<EOF
Even though large tracts of Europe and many old and famous states
have fallen or may fall into the grip of the Gestapo and all the
odious apparatus of Nazi rule, we shall not flag or fail.
We shall go on to the end, we shall fight in France,
we shall fight on the seas and oceans,
we shall fight with growing confidence and growing strength in the air,
we shall defend our Island whatever the cost may be,
we shall fight on the beaches, we shall fight on the landing grounds,
we shall fight in the fields and in the streets,
we shall fight in the hills; We shall never surrender.
EOF
    FACIT_LOG=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_LOG} <<EOF
fifth part
fourth part
third part
second part
first part
EOF
    ACTUAL_FILE=$(mktemp /tmp/XXXXXXXX)
    cat speech.txt > ${ACTUAL_FILE}
    ACTUAL_LOG=$(mktemp /tmp/XXXXXXXX)
    git log --format='%s' > ${ACTUAL_LOG}

    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_LOG} ${ACTUAL_LOG} &> /dev/null
    R2=$? 
    
    if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    then
    	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi

    rm ${FACIT_FILE} ${ACTUAL_FILE} \
       ${FACIT_BRANCH} ${ACTUAL_BRANCH} \
       ${FACIT_LOG} ${ACTUAL_LOG} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
