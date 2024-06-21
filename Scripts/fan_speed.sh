#!/bin/bash

# Function to get CPU and GPU fan speeds
get_fan_speeds() {
    cpu_fan=$(sensors | grep 'cpu_fan' | awk '{print $2}')
    gpu_fan=$(sensors | grep 'gpu_fan' | awk '{print $2}')

    # Display RPM or "N/A" if the fan speed is zero or not detected
    if [ "$cpu_fan" = "0" ] || [ -z "$cpu_fan" ]; then
        cpu_fan="N/A"
    fi
    if [ "$gpu_fan" = "0" ] || [ -z "$gpu_fan" ]; then
        gpu_fan="N/A"
    fi

    echo "CPU Fan: $cpu_fan RPM, GPU Fan: $gpu_fan RPM"
}

# Print the fan speeds
get_fan_speeds

