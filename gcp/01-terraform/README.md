# Terraform directory

Here you will find the Terraform modules that instantiate all Google Cloud Platform services needed to create the pipeline.

The `resources` directory contains files to upload to a GCS bucket such as the raw data CSV files and the PySpark job.

First, you need to decompress the CSV files included in raw_data.zip

```bash
# Run command inside 01-terraform directory
unzip resources/raw_data.zip -d resources
```

Next, edit the `terraform.tfvars` file as needed, you might only need to replace the first line with your GCP projectID.

Once the CSV files are extracted in the `resources` directory, `terraform.tfvars` file is setup and you are authenticated to GCP, apply terraform blocks with:

```bash
# Run command inside 01-terraform directory
terraform init
terraform apply
```

Type `yes` to confirm. 

In case of error, you might need to set the `GOOGLE_PROJECT` variable prior to `terraform apply` as follows:

```bash
# Run command inside 01-terraform directory
export GOOGLE_PROJECT=your-project-id
terraform apply
```

Now you are good to go to install Airflow in your GKE cluster.

If you wish to tear down the infrastructure, run

```bash
# Run command inside 01-terraform directory
terraform destroy
```