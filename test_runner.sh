#!/bin/bash

# NOTE: You should run "sudo chmod +x test_runner.sh" to it work
# Usage example: "./test_runner <dir_or_file> <times | default = 1>"

# Function to run Jest tests on a single file
run_jest_tests_on_file() {
    local file="$1"
    echo "[IN PROGRESS] '$file'"
    
    # Run Jest tests for the file and capture the exit code
    npx jest "$file" --silent
    local jest_exit_code=$?

    # Check if Jest encountered test failures
    if [ $jest_exit_code -ne 0 ]; then
        echo "Tests failed in file '$file'"
        ((failure_count++))
    else
        echo "Tests passed in file '$file'"
        ((success_count++))
    fi
}

calculate_total_time() {
    end_time=$(date +%s)
    total_time=$((end_time - start_time))
    echo "Time: $total_time s"
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory or file> [<iterations>]"
    exit 1
fi

# Record start time
start_time=$(date +%s)

# Initialize counters for successes and failures
success_count=0
failure_count=0

# Check if the provided argument is a directory or file
if [ -d "$1" ]; then
    # If it's a directory, proceed to run Jest tests on all files inside the directory

    # Check if the number of iterations is provided as the second argument
    if [ $# -eq 2 ]; then
        iterations="$2"
    else
        iterations=1
    fi

    # Check if the provided directory exists
    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' not found."
        exit 1
    fi

    # Find all test files in the specified directory
    test_files=$(find "$1" -type f -name "*.spec.tsx")

    # Run Jest tests for each test file for the specified number of iterations
    for ((i=1; i<=$iterations; i++)); do
        echo ""
        echo "Step $i/$iterations"
        for test_file in $test_files; do
            run_jest_tests_on_file "$test_file"
        done
    done
else
    # If it's a file, run Jest tests on that file

    # Check if the number of iterations is provided as the second argument
    if [ $# -eq 2 ]; then
        iterations="$2"
    else
        iterations=1
    fi

    # Run Jest tests for the provided file for the specified number of iterations
    for ((i=1; i<=$iterations; i++)); do
        echo ""
        echo "Step $i/$iterations"
        run_jest_tests_on_file "$1"
    done
fi

# Print the total number of successes and failures
echo ""
echo ""
echo "Total successes: $success_count"
echo "Total failures: $failure_count"
calculate_total_time
echo ""
