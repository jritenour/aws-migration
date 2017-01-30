require 'aws-sdk'
require 'rest-client'


# Variable - plan for use in the context of CFME will be to pull the AWS credentails from CFME provider, and use that to populate dropdown lists for region, and S3 bucket. object will be the S3 object (path/file) name, and will be created from uploaded disk
access_key = ''
secret_key = ''
region = ''
bucket = ''
object = ''
file = ''


#To do - figure out how to handle conversion of source format to RAW.  Probably best to use Ansible for this, but need to play around and figure out what works best and is most supportable

upload=Aws::S3::Resource.new(region: region, access_key_id: access_key, secret_access_key: secret_key)
obj=upload.bucket(bucket).object(object)
obj.upload_file('/tmp/rhel7test.qcow2')

#To do - maybe add option for architecture type? 
image=Aws::EC2::Resource.new(region: region, access_key_id: access_key, secret_access_key: secret_key)
image.import_image({
dry_run:false,
description: "RHEL 7",
disk_containers: [
{
description: "RHEL 7",
format: "raw",
user_bucket: {
s3_bucket: bucket,
s3_key: object,
},
},
],
architecture: 'x86_64',
})
