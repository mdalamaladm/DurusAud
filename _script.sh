format="${1:-mp3}"
source=$DURUSAUD_SOURCE
pathraw=$source/RAW
pathedited=$source/EDITED
darscodes=()
nums=()
rawtimes=()
middles=()
invalid=()
edited=()
encoder="libmp3lame"

if [[ $format == "mp3" ]]; then
  encoder="libmp3lame"
elif [[ $format == "m4a" ]]; then
  encoder="libfdk_aac"
fi


get_syaikhcode () {
  local data=$(get_splitted 0 $1)
  
  echo $data
}

get_darscodes () {
  darscodes=()
  
  local data=$(get_splitted 1 $1)
  
  local IFS='-'
  read -r -a darscodes <<< $data
}

get_nums () {
  nums=()
  
  local data=$(get_splitted 2 $1)
  
  local IFS='-'
  read -r -a nums <<< $data
}

get_rawtimes () {
  rawtimes=()
  
  local data=$(get_splitted 3 $1)
  
  local IFS='_'
  read -r -a rawtimes <<< $data
}

get_pure_startend () {
  local data
  local IFS='('
  read -r -a data <<< $1
  
  echo ${data[0]}
}

get_middles () {
  middles=()
  
  local data
  local IFS='('
  read -r -a data <<< $1
  
  local IFS='='
  read -r -a middles <<< ${data[1]: 0: -1}
}

get_splitted () {
  local arr
  local IFS=']'
  read -r -a arr <<< "$2"
  echo ${arr[$1]:1}
}

get_splitted_length () {
  local arr
  local IFS=']'
  read -r -a arr <<< "$1"
  echo ${#arr[@]}
}

get_arnum () {
  local IFS=' '
  read -r -a res <<< "$1"
  echo ${res[-1]:0:-4}
}

get_start () {
  local IFS='-'
  local time
  read -r -a time <<< $1
  echo "${time[0]}"
}

get_end () {
  local IFS='-'
  local time
  read -r -a time <<< $1
  echo "${time[1]}"
}

get_second_milisecond () {
  local IFS="^"
  local res
  read -r -a res <<< $1
  
  if [[ ${res[1]} == '' ]]; then
    echo "${res[0]: -2}"
  else
    echo "${res[0]: -2}.${res[1]}"
  fi
}

get_hour_minute () {
  local IFS="^"
  local res
  read -r -a res <<< $1
  
  local minute=${res[0]: 0: -2}
  if [[ $minute == '' ]]; then
    minute=0
  fi
  minute=$(( 10#$minute ))
  
  local hour=$(( $minute/60 ))
  minute=$(pad_two_zeros $(($minute-($hour*60))))
  hour=$(pad_two_zeros $hour)
  
  echo "$hour:$minute"
}

get_time () {
  local secondmilisecond="$(get_second_milisecond $1)"
  local hourminute="$(get_hour_minute $1)"

  echo "$hourminute:$secondmilisecond"
}

time_to_second () {
  local IFS=':'
  local res
  read -r -a res <<< $1
  local IFS="."
  local res2
  read -r -a res2 <<< ${res[2]}
  

  local hour=${res[0]}
  if [[ $hour == '' ]]; then
    hour=0
  fi
  hour=$(( 10#$hour ))
  
  local minute=${res[1]}
  if [[ $minute == '' ]]; then
    minute=0
  fi
  minute=$(( 10#$minute ))
  
  local second=${res2[0]}
  if [[ $second == '' ]]; then
    second=0
  fi
  second=$(( 10#$second ))
  
  local milisecond=${res2[1]}
  
  local secondtotal=$((( $hour*60*60 )+( $minute*60 )+ $second ))
  
  if [[ ${res2[1]} == '' ]]; then
    echo "$secondtotal"
  else
    echo "$secondtotal.$milisecond"
  fi
}

pad_two_zeros () {
  if [[ $1 -gt 9 ]]; then
    echo $1
  else
    echo "0$1"
  fi
}

num_to_arnum () {
  local num1=${1//1/١}
  local num2=${num1//2/٢}
  local num3=${num2//3/٣}
  local num4=${num3//4/٤}
  local num5=${num4//5/٥}
  local num6=${num5//6/٦}
  local num7=${num6//7/٧}
  local num8=${num7//8/٨}
  local num9=${num8//9/٩}
  local res=${num9//0/٠}
  echo $res
}

arnum_to_num () {
  local num1=${1//١/1}
  local num2=${num1//٢/2}
  local num3=${num2//٣/3}
  local num4=${num3//٤/4}
  local num5=${num4//٥/5}
  local num6=${num5//٦/6}
  local num7=${num6//٧/7}
  local num8=${num7//٨/8}
  local num9=${num8//٩/9}
  local res=${num9//٠/0}
  echo $res
}

escape_apost () {
  local IFS="'"
  local res
  read -r -a res <<< $1
  
  local textres=''
  
  for ridx in ${!res[@]}; do
    if [[ ridx == 0 ]]; then
      textres="${res[$ridx]}"
    else
      textres="$textres'\'${res[$ridx]}"
    fi
  done
  
  echo $textres
}

check_concat () {
  local IFS="("
  local res
  read -r -a res <<< $1
  
  if [[ ${#res[@]} == 2 ]]; then
    echo "1"
  else
    echo "0"
  fi
}

get_pure_num () {
  local IFS="("
  local res
  read -r -a res <<< $1
  
  echo ${res[0]}
}

get_ext () {
  local IFS="."
  local res
  read -r -a res <<< $1
  
  echo ${res[-1]}
}

get_custom_name () {
  while IFS= read -r line; do
    local IFS="="
    local res
    read -r -a res <<< $line
    # Process each 'line' here
    if [[ $1 == ${res[0]} ]]; then
      echo ${res[1]}
    fi
  done < "$DURUSAUD_SOURCE/custom.txt"
}

get_syaikhname () {
  while IFS= read -r line; do
    local IFS="="
    local res
    read -r -a res <<< $line
    # Process each 'line' here
    if [[ $1 == ${res[0]} ]]; then
      echo ${res[1]}
    fi
  done < "$DURUSAUD_SOURCE/syaikh.txt"
}

get_darsname () {
  while IFS= read -r line; do
    local IFS="="
    local res
    read -r -a res <<< $line
    # Process each 'line' here
    if [[ $1 == ${res[0]} ]]; then
      echo ${res[1]}
    fi
  done < "$DURUSAUD_SOURCE/dars.txt"
}

convert () {
  raw=$1
  syaikhcode=$2
  darscode=$3
  num=$4
  format=$5
  start=$6
  end=$7
  
  ffmpeg \
    -ss $start \
    -to $end \
    -i $pathraw/"$raw" \
    -i $source/ALBUM/"${syaikhcode}_$darscode.jpg" \
    -c:v copy \
    -c:a $encoder \
    -b:a 32k \
    -disposition:v:0 attached_pic \
    -map 0:0 \
    -map 1:0  \
    -id3v2_version 3 \
    -metadata title="" \
    -metadata artist="$(get_syaikhname $syaikhcode)" \
    -metadata album="$(get_darsname $darscode)" \
    "$pathedited/$(get_syaikhname $syaikhcode)/$(get_darsname $darscode)/$(get_darsname $darscode) - $(num_to_arnum $num).$format"
}

convertconcat () {
  syaikhcode=$1
  darscode=$2
  num=$3
  format=$4
  txtname=$5
  
  ffmpeg \
    -f concat \
    -safe 0 \
    -i "$pathraw"/"$txtname" \
    -i $source/ALBUM/"${syaikhcode}_$darscode.jpg" \
    -c:v copy \
    -c:a $encoder \
    -b:a 32k \
    -disposition:v:0 attached_pic \
    -map 0:0 \
    -map 1:0  \
    -id3v2_version 3 \
    -metadata title="" \
    -metadata artist="$(get_syaikhname $syaikhcode)" \
    -metadata album="$(get_darsname $darscode)" \
    "$pathedited/$(get_syaikhname $syaikhcode)/$(get_darsname $darscode)/$(get_darsname $darscode) - $(num_to_arnum $num).$format"
}

edit () {
  local raw=$1
  local startend=$2 
  local syaikhcode=$3 
  local darscode=$4 
  local num=$5
  local isconcat=$6
  
  local start="$(get_time "$(get_start $startend)")" # Get start time only and then format it to mm:ss.S or mm:ss, example: 2:08.3
  local end="$(get_time "$(get_end $startend)")" # Get end time only and then format it to mm:ss.S or mm:ss, example: 45:20
  local startsecond=$(time_to_second $start) # Get start time with seconds format, example: 128.3
  local endsecond=$(time_to_second $end) # Get end time with seconds format, example: 2720
  
  # Differ .txt file name between removed middle audio and separate parts audio
  local txtname
  
  if [[ $isconcat == "0" ]]; then
    txtname="cutmiddle.txt"
  else
    txtname="${syaikhcode}_${darscode}_$num.txt"
  fi

  # 3 conditions:
  # 1. If has middles, handle middles with .txt file. It also includes separate parts audio with middle in it
  # 2. Else if it's handle separated parts audio, handle separate parts with .txt file
  # 3. If Neither middle nor separate parts, handle single audio without the middle
  if [[ ${#middles[@]} -gt 0 ]]; then
    # Looping for each range of middle time
    for mididx in ${!middles[@]}; do
      local middletime=${middles[$mididx]}

      # Get start and end of each range, with mm:ss.S format and seconds format
      local middlestart="$(get_time "$(get_start $middletime)")"
      local middleend="$(get_time "$(get_end $middleend)")"
      local middlestartsecond=$(time_to_second $middlestart)
      local middleendsecond=$(time_to_second $middleend)
      
      # Create config file for middle removed audio or separated parts audio
      touch "$pathraw"/"$txtname"
      chmod +x "$pathraw"/"$txtname"
      
      # Handle config file according to range conditions
      if [[ ${#middles[@]} == 1 ]]; then
        printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $middlestartsecond\n" >> "$pathraw"/"$txtname"
        printf "file '$pathraw/$raw'\ninpoint $middleendsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
      elif [[ $mididx == 0 ]]; then
        printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $middlestartsecond\nfile '$pathraw/$raw'\ninpoint $middleendsecond\n" >> "$pathraw"/"$txtname"
      elif [[ $mididx == $((${#middles[@]} - 1)) ]]; then
        printf "outpoint $middlestartsecond\nfile '$pathraw/$raw'\ninpoint $middleendsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
      else
        printf "outpoint $middlestartsecond\nfile '$pathraw/$raw'\ninpoint $middleendsecond\n" >> "$pathraw"/"$txtname"
      fi
    done
    
    # If it is single audio, immediately edit the audio with the config file, else, it will run it later
    if [[ $isconcat == "0" ]]; then
      # Run FFMPEG with config file
      convertconcat $syaikhcode $darscode $num $format "$txtname"
  
      middles=()
  
      rm "$pathraw"/"$txtname"
    fi
  elif [[ $isconcat == "1" ]]; then
    printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
  else
    # Run FFMPEG
    convert "$raw" $syaikhcode $darscode $num $format $start $end
  fi
}

run_txt_concat () {
  # Looping all files
  for raw in $(ls -v $pathraw); do
    local ext="$(get_ext "$raw")"
    
    # If file is not config file, skip
    if [[ $ext != 'txt' ]]; then
      continue
    fi

    # Get file config name
    local IFS="/"
    local res
    read -r -a res <<< $raw
    local txtname=${res[-1]}
    
    # Extract syaikh code, dars code, and dars num for config file name
    local IFS="_"
    read -r -a res <<< $txtname
    local syaikhcode=${res[0]}
    local darscode=${res[1]}
    local num=${res[2]: 0: -4}
    
    # Run FFMPEG with config file
    convertconcat $syaikhcode $darscode $num $format "$txtname"
      
    rm "$raw"
  done
}

IFS=$'\n'
set -o noglob

main () {
  # Looping each audio file in RAW folder
  for raw in $(ls -v $pathraw); do
    local ext="$(get_ext "$raw")"
    
    # If file is config file, skip
    if [[ $ext == 'txt' ]]; then
      continue
    fi
    
    get_darscodes $raw # Get all code for each dars in an array, example: (AQAM KAT)
    get_nums $raw # Get all number for each dars in an array, example: (12 20)
    get_rawtimes $raw # Get All start time and end time for each dars in an array, example: (208^3-4520 130-3520^5)
    local syaikhcode="$(get_syaikhcode $raw)" # Get a code of syaikh for these dars
    
    # Looping each dars
    for codeidx in ${!darscodes[@]}; do
      local darscode=${darscodes[$codeidx]}
      local num=${nums[$codeidx]}
      local rawtime=${rawtimes[$codeidx]}
      local startend="$(get_pure_startend $rawtime)" # Get pure start time and end time, without it's middle time
      local rawlength="$(get_splitted_length $raw)" # Get how many metadata included in file name
      local isconcat=$(check_concat $num) # Check if dars number is separated into parts, so it will be concatenated
      local purenum=$(get_pure_num $num) # Get pure dars num, without part number
      
      get_middles $rawtime # Get all range of time in the middle, between start time and end time, so it will be removed
      
      # If metadata is completed, and they are: Syaikh code, Dars code, Dars number, Start time and end time
      if [[ $rawlength == "5" ]]; then
        # Create syaikh folder if not yet created
        [ ! -d "$pathedited"/"$(get_syaikhname $syaikhcode)" ] && mkdir -p "$pathedited"/"$(get_syaikhname $syaikhcode)"
        
        # Create dars folder if not yet created
        [ ! -d "$pathedited"/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)" ] && mkdir -p "$pathedited"/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)"
        
        # If the audio file is already edited, skip it, else, proceed the edit
        if ls $pathedited/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)" 2>/dev/null | grep -q "$(get_darsname $darscode) - $(num_to_arnum $purenum).$format" 2>/dev/null; then :
        elif ls $pathedited/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)" 2>/dev/null  | grep -q get_custom_name "${syaikhcode}_${darscode}_$purenum" 2>/dev/null
          then :
        else
          edit "$raw" "$startend" "$syaikhcode" "$darscode" "$purenum" "$isconcat"
        fi
      fi
    done
  done

  # Run FFMPEG with config file for separated parts audio
  run_txt_concat
}

main
