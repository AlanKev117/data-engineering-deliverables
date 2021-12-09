# Prerequisites

You need to follow some first steps prior to deploy the data pipeline

## Required software

Install the following tools according to your OS

- terraform (Terraform CLI tool)
- unzip (.zip file extractor)
- Google Cloud SDK (provides gcloud, gsutil, and bq commands)
- kubectl (Kubernetes cluster CLI manager)
- helm (Kubernetes Package Manager)

## Auth to GCP

After you've installed the `gcloud` SDK, initialize it by running the following command.

```bash
gcloud init
```

This will authorize the SDK to access GCP using your user account credentials and add the SDK to your PATH. This steps requires you to login and select the project you want to work in. 

Finally, add your account to the Application Default Credentials (ADC). This will allow Terraform to access these credentials to provision resources on GCloud.

```bash
gcloud auth application-default login
```