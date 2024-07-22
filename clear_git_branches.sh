#!/bin/bash

# List of branches to keep
BRANCHES_TO_KEEP=("main")

# Get all local branches
ALL_BRANCHES=$(git branch --list | sed 's/* //')

# Loop through each branch
for BRANCH in $ALL_BRANCHES; do
    # Check if the branch is in the keep list
    KEEP=0
    for KEEP_BRANCH in "${BRANCHES_TO_KEEP[@]}"; do
        if [ "$BRANCH" == "$KEEP_BRANCH" ]; then
            KEEP=1
            break
        fi
    done

    # If the branch is not in the keep list, delete it
    if [ $KEEP -eq 0 ]; then
        echo "Deleting branch: $BRANCH"
        git branch -D "$BRANCH"
    fi
done

