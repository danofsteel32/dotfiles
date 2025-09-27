#!/bin/bash

bat_zero_dir="/sys/class/power_supply/BAT0/"
bat_zero_full=$(cat "${bat_zero_dir}/energy_full")
bat_zero_now=$(cat "${bat_zero_dir}/energy_now")

bat_one_dir="/sys/class/power_supply/BAT1/"
bat_one_full=$(cat "${bat_one_dir}/energy_full")
bat_one_now=$(cat "${bat_one_dir}/energy_now")

total_now=$(echo "${bat_zero_now}+${bat_one_now}" | bc)
total_full=$(echo "${bat_zero_full}+${bat_one_full}" | bc)

percentage=$(echo "scale=2;(${total_now}/${total_full})" | bc -l)

echo ${percentage}
