aws_region = "us-east-1"
sse_algorithm = "AES256" 
profile       = "dev"
role_arn     = "arn:aws:iam::317380420770:role/dev-readandwrite"
buckets = [
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "archived-new-energy-raw-data",
    //     lifecycle_name = "standard"
    // },
    {
        bucket_name = "arrikto",
        lifecycle_name = "standard"
    },
    {
        bucket_name = "assetsim",
        lifecycle_name = "standard"
    },
    {
        bucket_name = "brazos2",
        lifecycle_name = "standard"
    }
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-run",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "analyser-poc",
    //     lifecycle_name = "standard"
    // },
    // {
    //     bucket_name = "last",
    //     lifecycle_name = "standard"
    // },


]

owner	                = "Energy Platform"
organization 	        = "Energy Platform"
scrum_team              = "Engineering"
management_avinstall	= "disable"
project	                = "development"
application_id	        = "337729"
business_unit	        = "BU:SNEUS"
customer                = "Energy Platform"
data_owner              = "Energy Platform"
standard_ia             = "180"
glacier                 = "730"
expiration              = "3650" 
id                      = "ne-lifecycle-s3"
enabled                 = true
prefix                  = "whole bucket"
environment             = "dev"
acl                     = "private"     
//cost_center             = "290047"
