dos2unix "$EDAUDIO_BASEPATH/_script.sh"
echo =========

source=$EDAUDIO_SOURCE
format="$1"

"$EDAUDIO_BASEPATH/_script.sh" $format
