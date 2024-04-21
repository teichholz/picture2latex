#!/bin/bash

if ! python3 -m pix2tex --help &> /dev/null; then
    echo "pix2tex is not installed. Please install it using 'pip install pix2tex'."
    exit 1
fi

scriptname=$(basename $0)
# mktemp also creates the file, so there might be issues regarding that
pipe=$(mktemp -p "/tmp" -t "$scriptname-fifo")
mkfifo -m777 $pipe

# Run the command in the background, redirecting its input to the fifo and output to the temp file
python3 -m pix2tex < $pipe &
# Make sure to cleanup process
(pid=$! && sleep 10 && kill $pid) &

waitAndSend() {
    # Send empty line to pix2tex process to initiate latex convert.
    # Note that stdout is redirected to the named pipe.
    # This works, since the input to python3 -m pix2tex is buffered and will be read as soon as the process is ready.
    echo ""
}

# Connect stdout to pipe, pyhton3 -m pix2tex doesn't block anymore
waitAndSend > $pipe

# Clean up, note that we can not simply kill the pypthon process here, since it is still processing
rm $pipe
