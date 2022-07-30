#Create an EC2
resource "aws_instance" "ec2" {
	ami                         = "ami-0eb7496c2e0403237"
	instance_type               = "${var.instance_type}"
	key_name                    = "${var.key_name}-ec2"
	security_groups             = ["${aws_security_group.public.id}"]
	subnet_id                   = "${aws_subnet.public-subnet.id}"
	associate_public_ip_address = true
	#user_data                   = "${data.template_file.provision.rendered}"
	#iam_instance_profile = "${aws_iam_instance_profile.some_profile.id}"
	lifecycle {
		create_before_destroy = true
	}
	tags = {
		"Name" = "${var.key_name}-ec2"
	}
	# Copies the ssh key file to home dir
	provisioner "file" {
		source      = "./${var.key_name}-keypair.pem"
		destination = "/home/ec2-user/${var.key_name}-keypair.pem"
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("${var.key_name}-keypair.pem")
			host        = self.public_ip
		}
	}
	//chmod key 400 on EC2 instance
	provisioner "remote-exec" {
		inline = ["chmod 400 ~/${var.key_name}-keypair.pem"]
		connection {
			type        = "ssh"
			user        = "ec2-user"
			private_key = file("${var.key_name}-keypair.pem")
			host        = self.public_ip
		}
	}
}
