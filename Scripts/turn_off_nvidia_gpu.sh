#!/bin/bash
sudo su -c "nvidia-smi -i 0000:01:00.0 -pm 0; nvidia-smi drain -p 0000:01:00.0 -m 1" # fully disable nvidia gpu

