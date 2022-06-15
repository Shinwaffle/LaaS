#!/bin/bash
echo "Deleting $1 instances..."
echo -e "You should see something like\nfedora$1\nand then insert random characters here\n if its different, read what is different."
for i in $(seq 1 $1);
do
	podman stop fedora$i
	podman rm fedora$i
done
