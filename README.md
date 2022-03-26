# Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

[Network Diagram](../master/images/01_ELK_Network_Diagram.jpg)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the Ansible Playbook files may be used to install only certain pieces of it, such as Filebeat.

  - Install_filebeat.yml

This document contains the following details:
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


## Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available and resilient, in addition to restricting access to the network.

- The load balancers, in general, will ensure that the application will still running and accepting requests even if any of the hosts within the Availability set fails. The more internal servers you have in the Availability Set will provide better redundancy to avoid interruption of service.

- From  the management perspective a Jump Box Server will allow sysadmins to have a point of entry into the network to manage resources. The access to this Jump box is controlled by security policies, allowing specific sources to reach it. With that, we are also preventing the need to expose other internal resources to the Internet.


Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the applications and system services.

- In our project, using Filebeat, we will retrieve logs from the docker containers in our Web servers to check system status
- With Metricbeat, we will perform system-level monitoring of our web servers (CPU, memory, filesys, disk IO, network)

The configuration details of each machine may be found below.
_Note: Use the [Markdown Table Generator](http://www.tablesgenerator.com/markdown_tables)

| Name     | Function         | IP Address | Operating System   |
|----------|------------------|------------|--------------------|
| Jump Box | MGMT GW          | 10.1.0.4   | Ubuntu Linux 18.04 |
| Web01    | LB Web Resource  | 10.1.0.5   | Ubuntu Linux 18.04 |
| Web02    | LB Web Resource  | 10.1.0.6   | Ubuntu Linux 18.04 |
| Web03    | LB Web Resource  | 10.1.0.7   | Ubuntu Linux 18.04 |
| ELK      | Kibana Server    | 10.2.1.4   | Ubuntu Linux 18.04 |

### Access Policies

The machines on the internal network are not exposed to the public Internet.

Only the Jump box, Load balancer Instance and ELK machines can accept connections from the Internet. Access to this machines is only allowed from the following IP addresses:

- 189.217.88.35

Machines within the network can only be accessed by the Jump box and ELK server for management and monitoring, although, the access is not wide open. Internal policies are in place to allow internal machines to talk to other within the same subnet or other subnets.

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible     | Allowed Public IP Addresses | Allowed Private IP Addresses |
|----------|-------------------------|-----------------------------|------------------------------|
| Jump Box | Yes                     | 189.217.88.35               |                              |
| ELK      | Yes                     | 189.217.88.35               | 10.1.0.4                     |
| Web01    | Yes over Load Balancer  | any                         | 10.1.0.4 10.2.1.4            |
| Web02    | Yes over Load Balancer  | any                         | 10.1.0.4 10.2.1.4            |
| Web03    | Yes over Load Balancer  | any                         | 10.1.0.4 10.2.1.4            |


### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because it helps sysadmins to perform installation of a diverse tools from a single automated task script (playbook) and not only that, that playbook can be used on different servers at the same time.

Here's a list of the advantages of using Ansible:

- Execute a set of tasks in multiple devices at the same time
- Addition of devices to the playbooks is done easily by just modifying small pieces of config
- Using YAML we can call different types of system commands: get, install, copy, start, restart, etc

In the case of the ELK deployment the Ansible playbook implements the following tasks:

- First, it makes sure to add more memory to the container in this case to 256MB
  name: More memory
  sysctl:
    name: vm.max_map_count
    value: '262144'
    state: present
    reload: yes

- Second, installs Docker on the server
  name: docker.io
    apt:
      update_cache: yes
      name: docker.io
      state: present

- Third, components needed by docker to enable ELK container
  name: Install pip3
    apt:
      force_apt_get: yes
      name: python3-pip
      state: present

  name: Install Docker python module
    pip:
      name: docker
      state: present

- Fourth, Download and run ELK (v7.6.1) as a container and publishes the ports for Kibana access
  name: download and launch a docker elk container
  docker_container:
    name: elk
    image: sebp/elk:761
    state: started
    published_ports:
      - 5601:5601
      - 9200:9200
      - 5044:5044


The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

images/docker_ps_output.jpg

### Target Machines & Beats
This ELK server is configured to monitor the following machines:

- Web01; Internal IP: 10.1.0.5
- Web02; Internal IP: 10.1.0.6
- Web03; Internal IP: 10.1.0.7


We have installed the following Beats on these machines:
- Web01; Internal IP: 10.1.0.5
- Web02; Internal IP: 10.1.0.6
- Web03; Internal IP: 10.1.0.7

These Beats allow us to collect the following information from each Web server running the dvwa container:

- Docker Metrics ECS CPU Usage (container itself)
- Docker Metrics ECS CPU Usage (dvwa application)
- Number of DOcker Containers and its status
- Memory usage ECS (dvwa application)
- Network usage ECS (dvwa application)


### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned:

SSH into the control node and follow the steps below:
- Copy the install_elk.yml file to /etc/ansible/files/
- Update the /etc/ansible/hosts file to include the webservers IP addresses in the proper section to be called by the playbooks
- Run the playbook, and navigate to your Webservers to check that the installation worked as expected.

  In this example, we have two defined sections on the hosts file:

  [webservers] - This name will be used if we use the host option within any playbook
  10.1.0.5 ansible_python_interpreter=/usr/bin/python3
  10.1.0.6 ansible_python_interpreter=/usr/bin/python3
  10.1.0.7 ansible_python_interpreter=/usr/bin/python3

  [elk] - This name will be used if we use the host option within any playbook
  10.2.1.4 ansible_python_interpreter=/usr/bin/python3


- _Which URL do you navigate to in order to check that the ELK server is running?
    http://<your_public_IP_in_Azure>:5601/app/kibana

*** BONUS ACTIVITY ***

Using Ansible Demo

1. With your Security rules in Azure defined, SSH into your Jump box. *Note: It will be needed to specify your Identity on the SSH-Key pair
  dcorrea@Mac-mini~% ssh -i /Users/appletoch/.ssh/azure_key RedAdmin@<your_public_IP_in_Azure>

2. Validate your containers list, we will launch the container in where we will be storing and running our Ansible playbooks:

  RedAdmin@JumpBox-Provisioner:~$ sudo docker container list -a
  CONTAINER ID   IMAGE                           COMMAND                  CREATED       STATUS                     PORTS     NAMES
  063758891ff0   cyberxsecurity/ansible          "/bin/sh -c /bin/bas…"   2 weeks ago   Exited (2) 7 days ago                youthful_jemison
  d0a23db964b6   cyberxsecurity/ansible          "/bin/sh -c /bin/bas…"   2 weeks ago   Exited (255) 2 weeks ago             sweet_kare
  035ed369ea5a   cyberxsecurity/ansible:latest   "/bin/sh -c /bin/bas…"   2 weeks ago   Exited (0) 3 minutes ago             pensive_wiles

3. Start the latest one by using the following command with the name of the container:

  RedAdmin@JumpBox-Provisioner:~$ sudo docker container start pensive_wiles

4. Start a session on the container:

  RedAdmin@JumpBox-Provisioner:~$ sudo docker container attach pensive_wiles
  root@035ed369ea5a:~#

  Note how the system prompt has changed into a different name, that means we are in the container running in our JumpBox

5. Validate ansible installation by moving into the /etc/ansible/ directory:

  root@035ed369ea5a:~# cd /etc/ansible/

6. Download the install_elk.yml as an example to be stored on this container:

    curl -x sssss install_elk.yml

7. Validate the hosts file and make sure the sections [webservers] and [elk] are present and make sure the IP addresses of your systems are correct.

    root@035ed369ea5a:/etc/ansible# cat hosts

    [webservers]
    10.1.0.5 ansible_python_interpreter=/usr/bin/python3
    10.1.0.6 ansible_python_interpreter=/usr/bin/python3

    [elk]
    10.2.1.4 ansible_python_interpreter=/usr/bin/python3
    #alpha.example.org
    #beta.example.org
    #192.168.1.100
    #192.168.1.110

    # If you have multiple hosts following a pattern you can specify
    # them like this:

    #www[001:006].example.com

    !--- Output omitted -----

    *Note: If you want to name the sections differently do not forget to update the host section in your playbooks ;)

8. Execute the playbook:

    root@035ed369ea5a:/etc/ansible# ansible-playbook roles/install_elk.yml

    At the end of the playbook it clearly states if any of the tasks had failed and the reason. If not errors are shown then we will validate the installation.

9. Log into your ELK server:

root@035ed369ea5a:/etc/ansible# ssh sysadmin@10.2.1.4
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1072-azure x86_64)

* Documentation:  https://help.ubuntu.com
* Management:     https://landscape.canonical.com
* Support:        https://ubuntu.com/advantage

System information as of Sat Mar 26 20:35:41 UTC 2022

System load:  0.07               Processes:              127
Usage of /:   18.1% of 28.90GB   Users logged in:        0
Memory usage: 35%                IP address for eth0:    10.2.1.4
Swap usage:   0%                 IP address for docker0: 172.17.0.1

* Super-optimized for small spaces - read how we shrank the memory
footprint of MicroK8s to make it the smallest full K8s around.

https://ubuntu.com/blog/microk8s-memory-optimisation

4 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

New release '20.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


*** System restart required ***
Last login: Sat Mar 26 20:05:26 2022 from 10.1.0.4
sysadmin@ELK-Server:~$

*Note: Look at the prompt, it has changed again, that is indicating us that we are inside the ELK server.

10. Let's validate that the ELK docker container is running:

sysadmin@ELK-Server:~$ sudo docker container list -a
CONTAINER ID   IMAGE          COMMAND                  CREATED       STATUS          PORTS                                                                              NAMES
fc6775dcab9c   sebp/elk:761   "/usr/local/bin/star…"   11 days ago   Up 39 minutes   0.0.0.0:5044->5044/tcp, 0.0.0.0:5601->5601/tcp, 0.0.0.0:9200->9200/tcp, 9300/tcp   elk
sysadmin@ELK-Server:~$

11. Let's validate access to Kibana GUI (Graphic User Interface)

    http://<your_public_IP_in_Azure>:5601/app/kibana

    If everything is working, you should see a webpage like this:

    images/kibana_gui.jpg
