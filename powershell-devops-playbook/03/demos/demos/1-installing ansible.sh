## Log into the CentOS host
ssh adam@<AnsibleControlNodeIp>

# Install the binaries
sudo yum install ansible

## Install pip if you don't have it already
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py

## Install Python WinRM support to contact Windows hosts
sudo pip install "pywinrm>=0.3.0"

## Would need to do this if Kerberos were used
# sudo yum install -y python-requests-kerberos

# Add to /etc/krb5.conf:
# [realms]
#   EXAMPLE.COM = {
#   kdc = ad.example.com
#  }

#[domain_realm]
#  .example.com = EXAMPLE.COM