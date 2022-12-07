#!/bin/bash
check_throttled () {
for (( i=0; i<n; i++)); do
  if (( $monitoring )); then echo -en "\033[1A\033[K"; fi
#  if (( $monitoring )); then echo -en "\033[1A"; fi
done

let n=0
if ((`vcgencmd get_throttled` & (1 << 0))); then
  echo -e "\033[K0: under-voltage"
  if (( $monitoring )); then ((n++)); fi
fi
if ((`vcgencmd get_throttled` & (1 << 1))); then
  echo -e "\033[K1: arm frequency capped"
  if (( $monitoring )); then ((n++)); fi
fi
if ((`vcgencmd get_throttled` & (1 << 3))); then
  echo -e "\033[K3: Soft temp limit reached"
  if (( $monitoring )); then ((n++)); fi
fi
if ((`vcgencmd get_throttled` & (1 << 16))); then
  echo -e "\033[K16: under-voltage has occured"
  if (( $monitoring )); then ((n++)); fi
fi
if ((`vcgencmd get_throttled` & (1 << 17))); then
  echo -e "\033[K17: arm frequency capped has occured"
  if (( $monitoring )); then n++; fi
fi
if ((`vcgencmd get_throttled` & (1 << 18))); then
  echo -e "\033[K18: throttling has occured"
  if (( $monitoring )); then ((n++)); fi
fi
if ((`vcgencmd get_throttled` & (1 << 19))); then
  echo -e "\033[K19: Soft temp limit has occured"
  if (( $monitoring )); then ((n++)); fi
fi
#(( n++ ))
#if (( $monitoring )); then echo -e "\033[${n}A"; fi
#echo -n "$n"
}

let timing=2

while getopts "hlmt:" options; do
  case "${options}" in
    h)
      echo "Get CPU throttle status in human readable format"
      echo "Usage:"
      echo "	-h:	Show help"
      echo "	-l:	Loop output"
      echo "	-m:     Monitoring mode, use with -l"
      echo "	-t: 	timing in seconds for -l"
      exit 0
      ;;
    l)
	(( loop = 1 ))
      ;;
    m)
      (( monitoring = 1))
      ;;
    t)
      let timing=${OPTARG}
      ;;
    :)
       echo "Error: No arguments?"
       exit 1
      ;;
    *)
      echo "Unknown error"
      exit 1
      ;;
  esac
done

if (( $loop )); then
  for (( ; ; )); do
    check_throttled
    sleep ${timing}
  done
else
  check_throttled
fi
