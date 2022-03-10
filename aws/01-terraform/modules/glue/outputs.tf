output "gj_name" {
    value = aws_glue_job.transform.id
}

output "gj_script_location" {
  value = aws_glue_job.transform.command[0].script_location
}