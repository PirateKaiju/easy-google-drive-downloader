#!/bin/bash

echo "Insert the path for a .txt file with the Google Drive links";
read filename; #TODO: ADD DEFAULT

filename='gdrive_links.txt' #TODO: THIS
log="download_log.log";
echo Start;

function download_file {
	#INPUT=$1;
	#read INPUT;#any unknown error made this just work with this,i'll analize and fix asap
	#unknown error made this the only way to get working by now: into the list begin by the second line of the file,the links have to be separated by an blank line,otherwise it will not work
	
	#echo $INPUT;
	#NO NEED FOR INTERMEDIATE VARIABLE FOR SIMPLE STUFF

	FILEID="$(echo $1 | sed -n 's#.*\/d\/\([^.]*\)\/.*#\1#;s#.*\?id\=\([^.]*\)\&.*#\1#;p')";
	#echo $FILEID
	FILENAME="$(wget -q --show-progress -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
	#echo $FILENAME
	CONFIRM_CODE=$(wget -q --show-progress --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$FILEID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
	wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM_CODE&id=$FILEID" -c -O "$FILENAME" && rm -rf /tmp/cookies.txt;
	if [ -f "$FILENAME" ]; then
		echo "file $FILENAME has been downloaded" >> $log
	else
		echo "file $FILENAME cannot be downloaded, some error has occurred" >> $log
	fi

}

count=0;

while read p; do 
	
	echo "Now downloading file $count"

	download_file $p & # LEGACYCOMMENT: if uncomment the "&" it will download all the files at the same time,it can crash if had lots of files
	pids[${count}]=$! 

	((count++))

  	#LEGACYCOMMENT: if download an really big amount of downloads(more than 10 could do it) google drive will notice that it is an algorithim and will reduce the speed and maby block your ip to download(sometimes it gives exceded amount of downloads into the files)
	#LEGACYCOMMENT: 	pidlist=("$pidlist[@]" $!)# $! = pid from process
	#TODO: STRATEGY FOR AVOID GDRIVE DETECTION -> MAYBE MAKE A POOL ON EVERY N LINKS AND THEN MAKE A DELAY?
done < $filename

#echo "${pids[@]}" #TODO: ENHANCE DEBUG FOR PID ARRAY

for subproc in "${pids[@]}"; do
	wait $subproc;
done

