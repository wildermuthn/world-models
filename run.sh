#!/usr/bin/env bash
. /opt/conda/etc/profile.d/conda.sh
conda activate ml
#
#: ${X11_DISPLAY_NO:=99}
#: ${X11_DISPLAY_GEOMETRY:=1024x768x24}
#
#
#DISPLAY=`tail -1 /etc/hosts | awk 'NF>1{print $NF}'`
#echo $DISPLAY
#export DISPLAY=$DISPLAY

#export DISPLAY=:20
#Xvfb :20 -screen 0 1366x768x16 &
#x11vnc -passwd password -display :20 -N -forever &

vnc4server -geometry 1400x1000 -depth 24
python traincontroller.py --logdir exp_dir --n-samples 12 --pop-size 36 --target-return 950 --display --max-workers 1