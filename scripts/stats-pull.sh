#!/bin/bash

echo "--- CPU ---"
uptime | awk -F'load average:' '{ print "Load:" $2 }'

echo "--- TEMP ---"
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    echo "$((cpu_temp / 1000))°C"
else
    echo "N/A"
fi

echo "--- UPTIME ---"
uptime -p | sed -e 's/up //' -e 's/ days\?,/d/' -e 's/ hours\?,/h/' -e 's/ minutes\?/m/'

echo "--- RAM ---"
free -h | awk '/^Mem:/ {print $3 " / " $2}'

echo "--- DISK ---"
df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'

echo "--- APPS ---"
# This logic checks if the status starts with "Up", if so, prints "Online"
docker ps -a --format "{{.Names}}: {{.Status}}" | while read line; do
    if echo "$line" | grep -q "Up"; then
        echo "${line%%:*}: Online"
    else
        echo "${line%%:*}: Offline"
    fi
done
