begin
  def log(level, message)  
  @method = 'aws_migration'
  $evm.log(level, "#{@method} - #{message}") 
end  

def dump_root()  
  log(:info, "Root:<$evm.root> Begin $evm.root.attributes")  
  $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}  
  log(:info, "Root:<$evm.root> End $evm.root.attributes")  
  log(:info, "")  
end  
  
dump_root  

require 'aws-sdk'
# Variable - plan for use in the context of CFME will be to pull the AWS credentails from CFME provider, and use that to populate dropdown lists for region, and S3 bucket. object will be the S3 object (path/file) name, and will be created from uploaded disk
$evm.log(:info, "Getting variables")
access_key = $evm.object['access_key']
secret_key = $evm.object.decrypt('secret_key')
region = $evm.object['region']
bucket = $evm.object['bucket']
object = $evm.object['object']
file = $evm.object['file']

#To do - figure out how to handle conversion of source format to RAW.  Probably best to use Ansible for this, but need to play around and figure out what works best and is most supportable

#upload=Aws::S3::Resource.new(region: region, access_key_id: access_key, secret_access_key: secret_key)
#obj=upload.bucket(bucket).object(object)
#obj.upload_file(file)

vm_mig= $evm.root['vm'] 
vm_mig.stop
  
$evm.log(:info, "#{vm_mig} has been shutdown")
$evm.log(:info, "Instantiating Ansible job")

$evm.instantiate("/AWS_Migration/ConfigurationManagement/AnsibleTower/Operations/JobTemplate/aws_migration?job_template_name=aws migration&limit=localhost")
$evm.log(:info, "Waiting for job to complete")

sleep 1000
 
#To do - maybe add option for architecture type?
$evm.log(:info, "Creating AMI from uploaded disk")
image=Aws::EC2::Client.new(region: region, access_key_id: access_key, secret_access_key: secret_key)
image.import_image({
dry_run:false,
description: "RHEL 6",
disk_containers: [
{
description: "RHEL 6",
format: "ova",
user_bucket: {
s3_bucket: bucket,
s3_key: object,
},
},
],
architecture: 'x86_64',
})
  $evm.log(:info, "Complete!")
end
