
# Instructions for running the Linux lab
https://github.com/Shinwaffle/LaaS

This repo is put on a usb stick for incoming students to use to setup their own instance
of this "Linux Lab" or, Linux as a Service. It contains several bash scripts and a python
script for the first version of this repo.

For the second version of the repo, I'm planning on reducing the amount of scripts needed
alongside a better implementation.

## Requirements
This needs to be ran on a Linux machine. This was tested on Ubuntu 21.10

The `podman` package also needs to be installed. To install on Ubuntu 20.10 and newer:
    sudo apt update
    sudo apt -y install podman
If you are running something else than Ubuntu 20.10 and newer, 
refer to this link <https://podman.io/getting-started/installation>.

Preferably this is all running on an SSD, as I did try with a hard drive and it did not work properly.

Make sure to disable (or uninstall, whatever) ufw or firewalld. You can uninstall by:
	sudo apt remove ufw firewalld

You have to be connected to the same network that the computers that the students are using are connected to.

Lastly, make sure you have enough ram for what you're running. Each instance takes up about ~600MB of RAM.
24GB of RAM should be plenty.

## Preparation
These require sudo privileges, so you can either login as root user or prefix every command with sudo

First, make sure podman is correctly installed.
	podman ps -a

Now, it is time for you to build the container. This will take the whole period or potentially longer.
	./build.sh | tee log

The build may or may not fail. If it fails, it is most likely one of the repositiries has been renamed.
You'll need to go into the Dockerfile and fix the issue. To edit the Dockerfile, do:
	nano Dockerfile

From this point on, your container should've been built. To check:
	podman images

And you should see a "localhost/fedora-vm:latest" (or similar), if you don't make sure the build succeded.

## Operation
You have two scripts which both take a number argument:

deploy.sh [number of instances]
	Deploys an X amount of instances. They will be listening on port 8001 and onwards.
	It works by taking the string "fedora" and adding a number to it. Then, it uses that string to
	name the instance. Additionally it adds that number to the base port 8000. If you run this script and
	still have instances running, it will throw an error saying that the instance already exists or the
	operation isn't supported. This script always starts at 1 and increments.
	In essence:
		fedora + 15
		8000 + 15
		fedora15 instance listening on port 8015

	Example:
		./deploy.sh 20
		Deploys 20 instances, which listen from port 8001 to port 8020.
		
delete.sh [number of instances]
	Destroys an X amount of instances. The deletion process works the same way that the deploy.sh script does,
	so it always starts at 1 and then increments. 
	Example:
		./delete.sh 20
		Destroys 20 instances

## Usage
Let's say you have 30 students that you need linux labs for. This is what you would do:
	sudo ./deploy.sh 30
And then once you're done:
	sudo ./delete.sh 30

That's it.

## Client Usage

They will head over to your ip and port (for example: 10.2.14.12:8007).
And then they will have to put in "containerized" as the username and password.
Another black box prompt will pop up and you'll have to put in the credentials again.
They won't see the password being entered in as they type, this is normal.
I wrote a python script to automate the login process, but it is quite janky.

Whenever a user wants to do a command with "sudo", the password will be "containerized".


## Improvements

The current design can be made a *lot* more efficient but requires some extra setup.
(I didn't have time to set it up)
So, if you're feeling up to the challenge, here goes:

Currently, each container runs their own instance of Tomcat and Apache Guacamole (guacd and client).
You could decouple the container from those applications and run it in one container,
then students would access that container, login, and then access a load balancer which provides
them with a fresh linux session (containerized, of course).

Here's a diagram:

(Linux container) <--\
                     |
(Linux container) <---- (ssh load balancer/proxy container) <--- (Tomcat/Apache Guacamole container) <------ (Web Browser) 
                     |
(Linux container) <--/

To be quite honest, I don't know why I didn't do this the first time but it is what it is. Anyways,
the linux containers would be just regular containers with openssh-server installed.
The Tomcat/Apache Guacamole container would point to the proxy which redirects it to a proper container.
The ssh load balancer/proxy, I imagine, would be nginx/express/flask/(any web server) and it would
have some internal logic to determine unoccupied containers or just spin up new containers
and redirect the client to the newly spun up container.

Now, whether you want to dynamically spin containers depending on demand is up to you.
Podman has an HTTP endpoint you could expose to spin up containers and would be my
recommend way of going about it.

The benefits of this approach is that you could run the same amount of containers as
before but with at least 5x less RAM. The downside is that it will use more CPU.
The downside isn't that bad though, as it takes decent CPU to run guac in the container
anyways and is way more scalable.
