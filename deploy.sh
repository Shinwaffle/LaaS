#!/bin/bash
echo "Deploying $1 instances..."
echo "if you see random characters and numbers, that means they were successfully executed"
echo -e "anything else, well i'd start worrying and reading them.\n\n"
for i in $(seq 1 $1);
do
	podman container run -d --restart=always --name=fedora$i -p $((8000 + $i)):80 localhost/fedora-vm:latest
	podman exec -d fedora$i ./var/lib/tomcat/bin/startup.sh
	podman exec -d fedora$i /usr/local/sbin/guacd
	podman exec -d fedora$i /usr/local/sbin/guacd
	# i dont know why the fuck it wont run unless i do it twice
	echo "Instance $i successfully deployed at port $((8000 + $i))"
done
