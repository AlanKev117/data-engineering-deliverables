# Airflow directory

This directory holds the resource files needed to create a custom Airflow Docker image, as  well as script and configuration files to install Airflow in a GKE cluster.

## Docker directory

This directory holds all of the files needed in the Airflow Docker image such as DAGs, dependencies, assets, etc.

- `assets/` contains only one SQL file with a schema table for the ODS.
- `custom_modules/` contains a custom Airflow operator that fetches a file from GCS, cleans it with Pandas and loads it to Cloud SQL.
- `dags/` contains three Airflow DAGs one for each stage of the pipeline (extract, transform, load).
- `docker-context-files/` contains a Python requirements file to be installed during the building of the Docker image. This requirements will be needed by the custom operator from above.
- `Dockerfile` is the blueprint file to create the custom Airflow docker image.

## Install Airflow in GKE

Once you have run the `terraform apply` command, which will create your GKE cluster (among other resources) you are ready to install Airflow on the cloud.

First, a brief description of the config files:

- `nfs-server.yaml` has `helm` configuration to create an NFS volume to store Airflow DAGs
- `values.yaml` has `helm` configuration to install Airflow with the *Airflow Helm Chart*. It contains a list of environments variables that need to be set in the cluster to configure connections, secrets, and so on.
- `airflow.env` it is a script-like `.env` file that will fetch outputs from Terraform and temporarily store them locally in env vars that will be read by the `[install_airflow_gke.sh](http://airflow-install-gke.sh)` script

To install Airflow in your cluster, run this command from within the `02-airflow` directory

```bash
# run inside 02-airflow
bash install_airflow_gke.sh
```

To remove installation done by `[install_airflow_gke.sh](http://airflow-install-gke.sh)`, run the uninstall script provided.

```bash
# run inside 02-airflow
bash uninstall_airflow_gke.sh
# it is recommended to run this command before terraform destroy
# so no storage remains after destory
```

Once the installation script is done, you can access the Airflow web server by forwarding port 8080 from Airflow web server pod to your computer.

```bash
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
# exit with ctrl + c
```

Now you can go to `[localhost:8080](http://localhost:8080)` from your web browser and access with user `admin` and password `admin` to view and invoke DAGs.