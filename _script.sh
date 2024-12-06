basepath=$1
pathraw=$basepath/RAW2
pathedited=$basepath/EDITED
darscodes=()
nums=()
rawtimes=()
middles=()
invalid=()
edited=()

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

get_startend () {
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
  hour=$(( 10#$hour ))
  local minute=${res[1]}
  minute=$(( 10#$minute ))
  local second=${res2[0]}
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
  printf '%02d' "${1#0}"
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

get_syaikhname () {
  if [[ $1 == 'AAd' ]]; then
    echo 'الأستاذ عرفات العدني'
  elif [[ $1 == 'ABr' ]]; then
    echo 'الشيخ أحمد بن عمر البركاني'
  elif [[ $1 == 'AWh' ]]; then
    echo 'الشيخ أحمد الوهطي'
  elif [[ $1 == 'MADh' ]]; then
    echo 'الشيخ محمد بن علي الضالعي'
  elif [[ $1 == 'MBw' ]]; then
    echo 'الشيخ محمد باوجيه'
  fi
}

get_darsname () {
  if [[ $1 == 'AAAW' ]]; then
    echo 'العقيدة الواسطية لشيخ الإسلام ابن تيمية'
  elif [[ $1 == 'AI' ]]; then
    echo 'الإعراب للشيخ عبد الله الفوزان'
  elif [[ $1 == 'AQAA' ]]; then
    echo 'القواعد الأربع للشيخ محمد بن عبد الوهاب'
  elif [[ $1 == 'AQAM' ]]; then
   echo 'القواعد المثلى للشيخ محمد بن صالح العثيمين'
  elif [[ $1 == 'AR' ]]; then
    echo 'الرسالة للإمام الشافعي'
  elif [[ $1 == 'KASy' ]]; then
    echo 'كشف الشبهات للشيخ محمد بن عبد الوهاب'
  elif [[ $1 == 'KAT' ]]; then
    echo 'كتاب التوحيد للشيخ محمد بن عبد الوهاب'
  elif [[ $1 == 'LAI' ]]; then
    echo 'لمعة الاعتقاد لابن قدامة المقدسي'
  elif [[ $1 == 'SIbA' ]]; then
    echo 'شرح ابن عقيل على ألفية ابن مالك'
  elif [[ $1 == 'TKAI' ]]; then
    echo 'تحقيق كللمة الإخلاص لابن رجب الحنبلي'
  fi
}

convert () {
  raw=$1
  syaikhcode=$2
  darscode=$3
  editedname=$4
  start=$5
  end=$6
  
  ffmpeg \
    -ss $start \
    -to $end \
    -i $pathraw/"$raw" \
    -i $basepath/ALBUM/"${syaikhcode}_$darscode.jpg" \
    -c:v copy \
    -c:a libfdk_aac \
    -b:a 32k \
    -disposition:v:0 attached_pic \
    -map 0:0 \
    -map 1:0  \
    -id3v2_version 3 \
    -metadata title="" \
    -metadata artist="$(get_syaikhname $syaikhcode)" \
    -metadata album="$(get_darsname $darscode)" \
    "$pathedited/$editedname"
}

convertconcat () {
  syaikhcode=$1
  darscode=$2
  editedname=$3
  txtname=$4
  
  ffmpeg \
    -f concat \
    -safe 0 \
    -i "$pathraw"/"$txtname" \
    -i $basepath/ALBUM/"${syaikhcode}_$darscode.jpg" \
    -c:v copy \
    -c:a libfdk_aac \
    -b:a 32k \
    -disposition:v:0 attached_pic \
    -map 0:0 \
    -map 1:0  \
    -id3v2_version 3 \
    -metadata title="" \
    -metadata artist="$(get_syaikhname $syaikhcode)" \
    -metadata album="$(get_darsname $darscode)" \
    "$pathedited/$editedname"
}

edit () {
  local raw=$1
  local startend=$2 
  local syaikhcode=$3 
  local darscode=$4 
  local num=$5
  local isconcat=$6
  
  local start="$(
    get_time "$(get_start $startend)"
    )"
  local startsecond=$(time_to_second $start)
  local end="$(
    get_time "$(get_end $startend)"
    )"
  local endsecond=$(time_to_second $end)
  local editedname="${syaikhcode}_${darscode}_$num.m4a"
  local txtname
  
  if [[ $isconcat == "0" ]]; then
    txtname=""$txtname""
  else
    txtname="${syaikhcode}_${darscode}_$num.txt"
  fi

  if [[ ${#middles[@]} -gt 0 ]]; then
    for mididx in ${!middles[@]}; do
      local midtime=${middles[$mididx]}
      local middlestartraw="$(get_start $midtime)"
      local midstart="$(get_time "$middlestartraw")"
      local midstartsecond=$(time_to_second $midstart)
      local middleendraw="$(get_end $midtime)"
      local midend="$(get_time "$middleendraw")"
      local midendsecond=$(time_to_second $midend)
      
      touch "$pathraw"/"$txtname"
      chmod +x "$pathraw"/"$txtname"
      
      if [[ ${#middles[@]} == 1 ]]; then
        printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $midstartsecond\n" >> "$pathraw"/"$txtname"
        printf "file '$pathraw/$raw'\ninpoint $midendsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
      elif [[ $mididx == 0 ]]; then
        printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $midstartsecond\nfile '$pathraw/$raw'\ninpoint $midendsecond\n" >> "$pathraw"/"$txtname"
      elif [[ $mididx == $((${#middles[@]} - 1)) ]]; then
        printf "outpoint $midstartsecond\nfile '$pathraw/$raw'\ninpoint $midendsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
      else
        printf "outpoint $midstartsecond\nfile '$pathraw/$raw'\ninpoint $midendsecond\n" >> "$pathraw"/"$txtname"
      fi
    done
    
    if [[ $isconcat == "0" ]]; then
      convertconcat $syaikhcode $darscode "$editedname" "cutmiddle.txt"

      middles=()
  
      rm "$pathraw"/"$txtname"
    fi
  elif [[ $isconcat == "1" ]]; then
    printf "file '$pathraw/$raw'\ninpoint $startsecond\noutpoint $endsecond\n" >> "$pathraw"/"$txtname"
  else
    convert "$raw" $syaikhcode $darscode "$editedname" $start $end
  fi
}

run_txt_concat () {
  set +o noglob

  for txtraw in "$pathraw"/*.txt; do
    local IFS="/"
    local res
    read -r -a res <<< $txtraw
    
    local txtname=${res[-1]}
    
    local IFS="_"
    read -r -a res <<< $txtname
    
    local syaikhcode=${res[0]}
    local darscode=${res[1]}
    local num=${res[2]: 0: -4}
    local editedname="${syaikhcode}_${darscode}_$num.m4a"
    
    local from=$pathedited/"${syaikhcode}_${darscode}_$num.m4a"
    local to=$basepath/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)"/"$(get_darsname $darscode) - $(num_to_arnum $num).m4a"
    
    if ls $pathedited | grep -q "${syaikhcode}_${darscode}_$num.m4a"; then
        cp $from $to
    else      
      convertconcat $syaikhcode $darscode "$editedname" "$txtname"
      
      rm "$txtraw"
      
      cp $from $to
    fi
  done
}

IFS=$'\n'
set -o noglob

main () {
  for raw in $(ls -v $pathraw); do
    get_darscodes $raw
    get_nums $raw
    get_rawtimes $raw
    local syaikhcode="$(get_syaikhcode $raw)"
    for codeidx in ${!darscodes[@]}; do
      local darscode=${darscodes[$codeidx]}
      local num=${nums[$codeidx]}
      local rawtime=${rawtimes[$codeidx]}
      local startend="$(get_startend $rawtime)"
      local rawlength="$(get_splitted_length $raw)"
      local isconcat=$(check_concat $num)
      local purenum=$(get_pure_num $num)
      
      get_middles $rawtime
      
      if [[ $rawlength == "5" ]]; then
        local from=$pathedited/"${syaikhcode}_${darscode}_$purenum.m4a"
        local to=$basepath/"$(get_syaikhname $syaikhcode)"/"$(get_darsname $darscode)"/"$(get_darsname $darscode) - $(num_to_arnum $purenum).m4a"
        
        if ls $pathedited | grep -q "${syaikhcode}_${darscode}_$purenum.m4a"; then
          cp $from $to
          
        else
          edit "$raw" "$startend" "$syaikhcode" "$darscode" "$purenum" "$isconcat"

          if [[ $isconcat == "0" ]]; then
            cp $from $to
          fi
        fi
      else
        invalid+=("${syaikhcode}_${darscode}_$purenum")
      fi
    done
  done

  run_txt_concat
}

main