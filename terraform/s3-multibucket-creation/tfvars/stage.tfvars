aws_region = "us-east-1"
sse_algorithm = "AES256" 
profile      = "prodtf"
role_arn     = "arn:aws:iam::651668690081:role/ep_servicerole"
buckets = [
    {
        bucket_name = "ne-raw-data-stage",
        team = "DE", 
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-cleansed-data-stage",
        team = "DE",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-curated-data-stage",
        team = "DE",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-feature-data-stage",
        team = "DS",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-trained-models-stage",
        team = "DS",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-predictions-stage",
        team = "DS",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-ds-curated-data-stage",
        team = "DS",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name = "ne-raw-app-data-stage",
        team = "FE",
        lifecycle_name = "standard",
        environment = "stage",
    },
    {
        bucket_name =  "ne-curated-app-data-stage",
        team = "FE",
        lifecycle_name = "standard",
        environment = "stage",
    },
]

cost_center  = "290047"
business_unit = "BU:SNEUS"
organization = "Energy Platform"

standard_ia = "180"
glacier = "730"
expiration = "3650" 
id              = "ne-lifecycle-s3"
enabled         = true
prefix          = "whole bucket"