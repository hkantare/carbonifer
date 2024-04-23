terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.64.2"
    }
  }
}

provider "ibm" {
}

resource "ibm_is_vpc" "example" {
  name = "example-vpc"
}

data "ibm_is_image" "example" {
  name = "ibm-centos-7-9-minimal-amd64-12"
}

resource "ibm_is_subnet" "example" {
  name            = "example-subnet"
  vpc             = ibm_is_vpc.example.id
  zone            = "us-south-1"
  ipv4_cidr_block = "10.240.0.0/24"
}

resource "ibm_is_ssh_key" "example" {
  name       = "example-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
}

resource "ibm_is_virtual_network_interface" "example"{
    name                                    = "example-vni"
    allow_ip_spoofing               = false
    enable_infrastructure_nat   = true
    primary_ip {
        auto_delete       = false
    address             = "10.240.0.8"
    }
    subnet   = ibm_is_subnet.example.id
}

resource "ibm_is_instance" "example" {
  name                      = "example-instance"
  image                     = data.ibm_is_image.example.id
  profile                   = "bx2d-128x512"
  metadata_service_enabled  = false

  boot_volume {
    encryption = "crn:v1:bluemix:public:kms:us-south:a/dffc98a0f1f0f95f6613b3b752286b87:e4a29d1a-2ef0-42a6-8fd2-350deb1c647e:key:5437653b-c4b1-447f-9646-b2a2a4cd6179"
  }

  primary_network_attachment {
    name = "vexample-primary-att"
    virtual_network_interface { 
      id = ibm_is_virtual_network_interface.example.id
    }
  }

  network_attachments {
    name = "example-network-att"
    virtual_network_interface {
      name = "example-net-vni"
            auto_delete = true
            enable_infrastructure_nat = true
            primary_ip {
                auto_delete     = true
                address         = "10.240.0.6"
            }
            subnet = ibm_is_subnet.example.id
    }
  }
  vpc  = ibm_is_vpc.example.id
  zone = ibm_is_subnet.example.zone
  keys = [ibm_is_ssh_key.example.id]

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
