#!/bin/bash
### convert.sh

export INPUT_AUDIO_PATH="<local input folder path>"
export OUTPUT_AUDIO_PATH="<local output folder path>"
echo $INPUT_AUDIO_PATH
echo $OUTPUT_AUDIO_PATH

date +"%T.%3N"
for x in $(find $INPUT_AUDIO_PATH -name "*.wav")
 do
   PREFIXPATH=${x%*/*}
   y=$(echo "$x" | cut -d"/" -f5)
         echo "$x"
         echo "$y"
   g=${y%%.*}
   ffmpeg -i "$x" -ar 8000 "$OUTPUT_AUDIO_PATH"/"$g".flac 
done
date +"%T.%3N"