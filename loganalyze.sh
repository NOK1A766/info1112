#!/bin/bash

# TODO
if [ "$#" == 0 ];
then
    dir=$PWD

elif [ "$#" == 1 ];
then
    if [ -d "$1" ];
    then
        dir=$(cd $1 && pwd)
    else
        echo -e "usage: arg needs to be a directory.\n"
        exit 1
    fi
else
    echo -e "usage: more than 1 arg is not allowed.\n"
    exit 2
fi

log_files=$(find "$dir" \
	-mindepth 1 \
	-maxdepth 1 \
	-type f \
	-mtime -7 \
	\( -name "*.log" -o -name "syslog" \)
)
if [ -z "$log_files" ]
then
    log_file_num=0
else
    log_file_num=$(printf '%s\n' "$log_files" | wc -l)
fi

if [ "$log_file_num" == 0 ]; then
    echo -e "No. of modified log files: 0\n"
    exit 0
fi

analysis_file="$HOME/analysisData.log"
summary_file="$HOME/summary.log"

total_error=0
max_error=-1
max_file=""

echo $dir
while IFS= read -r file;
do
    error_count=$(grep -ic -- "error" "$file")
    {
        echo "********************"
        echo "Filename: $file <No. of errors found = $error_count>"
    } | tee -a $analysis_file
    total_error=$((total_error + error_count))

    if [ $error_count -gt $max_error ];
    then
        max_error=$error_count
        max_file=$file
    fi
done <<< $log_files
echo "-----------------"

{
    echo "Total errors found: $total_error"
    echo "File with the max errors: $max_file, <error-count: $max_error>"
} | tee $summary_file


