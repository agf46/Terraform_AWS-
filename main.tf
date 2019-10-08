provider "aws" {
    region = "us-east-1"
}
resource "aws_instance" "example" {
    ami = "ami-40d28157"
    instance_type = "t2.micro" 
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello World!" > index.html
                nohub busybox httpd -f -p "${var.server_port}" &
                EOF
    tags = {
        Name = "terraform-example"
    }
}
variable "server_port"{
    description = " The port the server will use for HTTP requests" 
    default = 8080
}
resource "aws_security_group" "instance" {
    name = "terraform-example-insatnce"

    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }
# Adding lifecycle support. This will create a copy/replacement of our tf state
lifecycle {
    create_before_destroy = true
}
}

# get available AZs on your AWS account 

/* data "aws_availability_zones" "all" {}

#resource "aws_autoscaling_group" "example" {
    #launch_configuration = "${aws_launch_configuration.example.id}"
    
    #pass available AZs on your AWS account from line 39 in code 
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    
    #add health check and register each elb to an EC2 instance. This is bootstrapped. 
    #load_balancers = ["{aws_elb.example.name}"]
    #health_check_type = "ELB"

    #min_size = 1 
    #max_size = 10

    #tags =  {
      #  key  = "Name"
      #  value = "terraform-asg-example"
      #  propogate_at_launch = true 
   # }
#}

# Create an elb with terraform
 resource "aws_elb" "example" {
     name = "terraform-elb-example" 
     availability_zones = ["${data.aws_availability_zones.all.names}"]
     security_groups = ["${aws_security_group.elb.id}"]
     # Route requests to elb

     listener {
         lb_port = 80
         lb_protocol = "http" 
         instance_port = "${var.server_port}"
         instance_protocol = "http" 
     }

 #Add health check so it can stop routing for unhealthy EC2 instances 

    health_check {
        healthy_threshold = 1
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    } 
 
 }

 # ELBs dont route traffic by default. So you need to route through ingress and allow incoming traffic 
 
 resource "aws_security_group" elb {
     name = "terraform-elb-example"

     ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }
    # Allow health_check 
    
     egress {
         from_port = 0
         to_port = 0
         protocol = "-1" 
         cidr_blocks = ["0.0.0.0/0"]
     }
 } */
 