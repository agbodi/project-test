


resource "aws_ami_from_instance" "jango_ami" {
	
	name = "jango_ami"
	source_instance_id = "${data.aws_instance.ec2.id}"
}
