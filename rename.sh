#!/bin/bash

if [ -z $1 ]; then
	echo "No command selected"
	exit
fi

# Check that necessary files exist.
if [ ! -f $2 ]; then
	echo "Input bibliography file does not exist"
	exit
fi

if [ ! -f JournalAbbreviationList ]; then
	echo "JournalAbbreviationList files does not exist"
	exit
fi

if [ ! -f JournalNamesList ]; then
	echo "JournalNamesList files does not exist"
	exit
fi

if [ $1 = "list" ]; then
	if [ -f "abbreviated-"$2 ]; then
		cat "abbreviated-"$2 | grep journal | uniq -u
		exit
	else
		echo "Run replace command first"
	fi
fi

if [ ! "$1" = "replace" ]; then
	exit
fi
#
# Check that JournalAbbreviationList and JournalNamesList corresponds
if [ ! $(cat JournalAbbreviationList | wc -l) = $(cat JournalNamesList | wc -l) ]; then
	exit
#	else 
#	echo "JournalNamesList and JournalAbbreviationList checks out."
fi

# Setup variables and inform user

outfile="abbreviated-"$2
IFS=$'\n'
Abbrlines=($(cat JournalAbbreviationList))
Namelines=($(cat JournalNamesList))
echo ""
echo "WARNING!: Continuing will remove $outfile and write new bibliography to this."
read -p "Do you want to continue [y/n]? "
if [ ! "$REPLY" = "y" ]; then
	exit
fi
rm $outfile
cp $2 $outfile


# Command to insert abbreviations
function replace() {
        # Generate search regex
        if grep -Rq "$journal" $outfile; then
	    echo "Replacing \"$journal\" with \"$jabbrev\""
            searchregex="journal[ ]*=[ ]*{$journal}"
            replaceregex="journal = {$jabbrev}"
            sedcommand="s/"$searchregex"/"$replaceregex"/Ig"
            escapedchar="'"
	    eval "gsed -i $escapedchar$sedcommand$escapedchar $outfile"
        else
           continue  
        fi
}

TitleCaseConverter() {
    gsed 's/.*/\L&/; s/[a-z]*/\u&/g' <<<"$1"    
}

for i in $(seq 1 $(cat JournalNamesList | wc -l) ); do
#	journal_anycase=${Namelines[$i-1]}
        journal=${Namelines[$i-1]}
#        journal="$(TitleCaseConverter "$journal_anycase")"
	jabbrev=${Abbrlines[$i-1]}
	replace
done
