#!/bin/bash
check_throttled () {
for (( i=0; i<n; i++)); do
  if (( $monitoring )); then echo -en "\033[1A\033[K"; fi
done

let n=0
(( `vcgencmd get_throttled` ))

if (( $temperature )); then
  echo -e "Temperature: `vcgencmd measure_temp`"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 0) )); then
  echo -e "under-voltage"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 1) )); then
  echo -e "arm frequency capped"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 3) )); then
  echo -e "Soft temp limit reached"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 16) )); then
  echo -e "under-voltage has occured"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 17) )); then
  echo -e "arm frequency capped has occured"
  if (( $monitoring )); then n++; fi
fi
if (( $throttled & (1 << 18) )); then
  echo -e "throttling has occured"
  if (( $monitoring )); then ((n++)); fi
fi
if (( $throttled & (1 << 19) )); then
  echo -e "Soft temp limit has occured"
  if (( $monitoring )); then ((n++)); fi
fi
if (( !($throttled ) )); then
  echo -e "No throttling has occured"
  if (( $monitoring )); then ((n++)); fi
fi
}

let timing=2

while getopts "hlmtd:" options; do
  case "${options}" in
    h)
      echo "Get CPU throttle status in human readable format"
      echo "Usage:"
      echo "	-h:	Show help"
      echo "	-l:	Loop output"
      echo "	-m:     Monitoring mode, use with -l"
      echo "	-t: 	measure temperature"
      echo "	-d: 	delay between measurements in seconds"
      exit 0
      ;;
    l)
	(( loop = 1 ))
      ;;
    t)
      (( temperature = 1 ))
      ;;
    m)
      (( monitoring = 1 ))
      ;;
    d)
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
