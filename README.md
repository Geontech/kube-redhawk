# Kube-REDHAWK

A repository for launching the [Docker-REDHAWK](https://github.com/Geontech/docker-redhawk) containers in a Kubernetes cluster.

## Prerequisites

* [Docker Engine](https://docs.docker.com/engine/install/centos/) (Tested with 19.03.12)
* [Docker Engine Post-installation Steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Stand Up Cluster

Install minikube.

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Show the version to make sure it installed.

```
minikube version
```

Start minikube and install `kubectl`.

```
minikube start
minikube kubectl -- get pods -A
```

Save your typing fingers for `kubectl` by adding the following lines to your **~/.bashrc**.

```
alias kubectl="minikube kubectl --"
```

Make sure your minikube installation has the CoreDNS add-on (if not, install with instructions [here](https://kubernetes.io/docs/tasks/administer-cluster/coredns/#installing-coredns)).

```
kubectl get services kube-dns --namespace=kube-system
```

## Setup Cluster Images

Build the REDHAWK development cluster image on the minikube node and copy all REDHAWK images to minikube.

```bash
cd redhawk-cluster-development/
docker build -t geontech/redhawk-cluster-development:2.2.5 .
cd ../
mkdir images && cd images
docker save -o redhawk-usrp.tar                geontech/redhawk-usrp:2.2.5
docker save -o redhawk-webserver.tar           geontech/redhawk-webserver:2.2.5
docker save -o redhawk-bu353s4.tar             geontech/redhawk-bu353s4:2.2.5
docker save -o redhawk-rtl2832u.tar            geontech/redhawk-rtl2832u:2.2.5
docker save -o redhawk-gpp.tar                 geontech/redhawk-gpp:2.2.5
docker save -o redhawk-domain.tar              geontech/redhawk-domain:2.2.5
docker save -o redhawk-development.tar         geontech/redhawk-development:2.2.5
docker save -o redhawk-runtime.tar             geontech/redhawk-runtime:2.2.5
docker save -o redhawk-omniserver.tar          geontech/redhawk-omniserver:2.2.5
docker save -o redhawk-base.tar                geontech/redhawk-base:2.2.5
docker save -o redhawk-cluster-development.tar geontech/redhawk-cluster-development:2.2.5
minikube cp redhawk-usrp.tar                   /home/docker/redhawk-usrp.tar
minikube cp redhawk-webserver.tar              /home/docker/redhawk-webserver.tar
minikube cp redhawk-bu353s4.tar                /home/docker/redhawk-bu353s4.tar
minikube cp redhawk-rtl2832u.tar               /home/docker/redhawk-rtl2832u.tar
minikube cp redhawk-gpp.tar                    /home/docker/redhawk-gpp.tar
minikube cp redhawk-domain.tar                 /home/docker/redhawk-domain.tar
minikube cp redhawk-development.tar            /home/docker/redhawk-development.tar
minikube cp redhawk-runtime.tar                /home/docker/redhawk-runtime.tar
minikube cp redhawk-omniserver.tar             /home/docker/redhawk-omniserver.tar
minikube cp redhawk-base.tar                   /home/docker/redhawk-base.tar
minikube cp redhawk-cluster-development.tar    /home/docker/redhawk-cluster-development.tar
```

Load the images on the minikube node with the following commands.

```bash
minikube ssh
docker load -i redhawk-usrp.tar
docker load -i redhawk-webserver.tar
docker load -i redhawk-bu353s4.tar
docker load -i redhawk-rtl2832u.tar
docker load -i redhawk-gpp.tar
docker load -i redhawk-domain.tar
docker load -i redhawk-development.tar
docker load -i redhawk-runtime.tar
docker load -i redhawk-omniserver.tar
docker load -i redhawk-base.tar
docker load -i redhawk-cluster-development.tar
exit
```

## Launch Kube-REDHAWK

Create the deployments and services by applying the YAML files to the cluster.

```bash
kubectl apply -f rh-core.yaml
kubectl apply -f rh-core-omniserver.yaml
kubectl apply -f rh-core-ssh.yaml
kubectl apply -f rh-gpp.yaml
```

Check on the status of the deployments, services, and pods.

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Inspect the NodePort of the `rh-core-ssh` service to make sure it is 30022.

```bash
kubectl describe services rh-core-ssh | grep NodePort
```

Get the Public IP of the cluster (this command might not work without minikube).

```bash
kubectl cluster-info
```

SSH directly in to the cluster on the NodePort and start the REDHAWK IDE.

```bash
ssh -X root@<CLUSTER_IP> -p 30022
# --> Password: redhawk
rhide &
```

## Test Kube-REDHAWK

Follow the instructions below in the REDHAWK IDE to validate Kube-REDHAWK is operational.

1. Click the **+** button in the "REDHAWK Explorer"
2. In the "New Domain Manager" dialog:
    1. Enter "REDHAWK_DEV" for the **Domain Name** textbox
    2. The **Display Name** textbox should auto-populate with "REDHAWK_DEV"
    3. Click **Finish**
3. Expand the **REDHAWK_DEV>Device Managers** node in the "REDHAWK Explorer" and verify that three GPP nodes exist
4. Right-click on the **REDHAWK_DEV** node in the "REDHAWK Explorer" and click **Launch Waveform...**
5. In the "Launch Waveform" dialog:
    1. Select **rh>basic_components_demo**
    2. Check the **Start the Waveform after launching** checkbox
    3. Click **Finish**
6. Expand the **REDHAWK_DEV>Waveforms** node in the "REDHAWK Explorer" and verify that the "rh.basic_components_demo" waveform was launched

Follow the instructions below in the REDHAWK IDE to test a development flow on Kube-REDHAWK.

1. Click **File>New>REDHAWK Waveform Project**
2. In the "New Waveform Project" dialog:
    1. Type "my_demo" in the **Project name** textbox
    2. Select the **Use existing waveform as a template** radio button
    3. Type "/var/redhawk/sdr/dom/waveforms/rh/basic_components_demo/basic_components_demo.sad.xml" in the **SAD File** textbox
    4. Click **Finish**
3. In the "my_demo" panel in the center-top of the screen:
    1. Select the **Overview** tab
    2. Click the **Generate Waveform** button in the top right-hand corner of the panel
    3. Click **OK** in the "Generate Files" dialog
4. Right-click **my_demo** in the "Project Explorer" panel on the left-hand side of the screen and click **Export to SDR**
6. Expand the **Target SDR>Waveforms** node in the "REDHAWK Explorer" and verify that the "my_demo" waveform is listed
4. Right-click on the **REDHAWK_DEV** node in the "REDHAWK Explorer" and click **Launch Waveform...**
5. In the "Launch Waveform" dialog:
    1. Select **my_demo**
    2. Check the **Start the Waveform after launching** checkbox
    3. Click **Finish**
6. Expand the **REDHAWK_DEV>Waveforms** node in the "REDHAWK Explorer" and verify that the "my_demo" waveform was launched

## Tear Down Kube-REDHAWK

Tear down the deployments and services in the reverse direction of the startup.

> IMPORTANT NOTE: The workspace and SDRROOT of the cluster are NOT saved!

```bash
kubectl delete deployment rh-gpp
kubectl delete service rh-core-ssh
kubectl delete service rh-core-omniserver
kubectl delete deployment rh-core
```

## Debug

It is helpful to view the logs of a container when something goes wrong.

```bash
kubectl logs <POD_NAME> -c <CONTAINER_NAME>
```

You can also get directly in to the shell of a running container.

```bash
kubectl exec --stdin --tty -c <CONTAINER_NAME> <POD_NAME> -- /bin/bash
```
