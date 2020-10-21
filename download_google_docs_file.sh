#!/bin/bash

function check_extension { #FORMAT: FILE_EXTENSION, EXTENSION_ARRAY 

	#TODO: USING DIRECT REFERENCE TO GLOBAL, CHANGE TO LOCAL
	if [[ " ${EXPECTEDEXTENSIONS[@]} " =~ " $FILEEXTENSION " ]]; then # IN PRACTICE, SAME AS USING A FOR
		#DO NOTHING
		echo "Found result for format $FILEEXTENSION "
	elif [ $1 = "html" ]; then
		FILEEXTENSION="zip"
	else
		FILEEXTENSION="pdf" #WHY?
		echo "Error: Unsupported Format" #SWAPPED FOR SOMETHING MORE GENERALISTIC
	fi
	#return; #TODO: EXPLICIT RETURN
}

echo "Insert the google doc url";
read FILEURL;
GOOGLE_SERVICEFILEID="$(echo $FILEURL | sed -n 's#.*\https\:\/\/docs\.google\.com\/\([^.]*\)\/d\/*.*#\1#;p')";
FILEID="$(echo $FILEURL | sed -n "s#.*\https\:\/\/docs\.google\.com\/$GOOGLE_SERVICEFILEID\/d\/\([^.]*\)\/.*#\1#;p")";
FILENAME="$(wget -q --show-progress --quiet -O - "https://drive.google.com/file/d/$FILEID/view" | sed -n -e 's!.*<title>\(.*\)\ \-\ Google\ Drive</title>.*!\1!p')";
case "$GOOGLE_SERVICEFILEID" in
	"document")
		echo "Insert the google document EXTENSION to download (Documents Supported formats are [docx/odt/rtf/PDF/txt/html/epub])";
		read FILEEXTENSION;

		EXPECTEDEXTENSIONS=( "docx" "odt" "rtf" "pdf" "txt" "epub" )
		check_extension $FILEEXTENSION $EXPECTEDEXTENSIONS 

		wget -q --show-progress -c "https://docs.google.com/document/export?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"\
		&& echo "" && echo "the file $FILENAME.$FILEEXTENSION has been fully downloaded" #TODO: MAYBE ENCAPSULATE THIS TOO #TODO: SET DEFAULT NAME FOR NON-NAMED 
	;;
	"spreadsheets")
		echo "Insert the google document EXTENSION to download (Presentations supported formats are [xlsx/ods/PDF/html/csv/tsv])";
		read FILEEXTENSION;
		EXPECTEDEXTENSIONS=( "xlsx" "ods" "pdf" "csv" "tsv" )
		check_extension $FILEEXTENSION $EXPECTEDEXTENSIONS 
		wget -q --show-progress -c "https://docs.google.com/spreadsheets/export?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"\
		&& echo "" && echo "the file $FILENAME.$FILEEXTENSION has been fully downloaded"
	;;
	"presentation")
		echo "Insert the google document EXTENSION to download(Presentations supported formats are [pptx/odp/PDF/txt/jpg/png/svg])";
		read FILEEXTENSION;
		EXPECTEDEXTENSIONS=( "pptx" "odp" "pdf" "txt" "jpg" "png" "svg" )
		check_extension $FILEEXTENSION $EXPECTEDEXTENSIONS 
		wget -q --show-progress -c "https://docs.google.com/presentation/export?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"\
		&& echo "" && echo "the file $FILENAME.$FILEEXTENSION has been fully downloaded"
	;;
	"drawings")
		echo "Insert the google document EXTENSION to download (if you insert a wrong one or not suportated file extension it may not work)";
		read FILEEXTENSION;
		EXPECTEDEXTENSIONS=( "jpg" "png" "svg" "pdf" )
		check_extension $FILEEXTENSION $EXPECTEDEXTENSIONS 
		wget -q --show-progress -c "https://docs.google.com/drawings/export?format=$FILEEXTENSION&id=$FILEID&includes_info_params=true" -O "$FILENAME.$FILEEXTENSION"\
		&& echo "" && echo "the file $FILENAME.$FILEEXTENSION has been fully downloaded"
	;;
	*)
		echo "Error: Unsupported Service Field"
	;;
esac
