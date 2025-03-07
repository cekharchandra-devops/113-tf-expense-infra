#!/bin/bash

environment=$1
component=$2

dnf install ansible -y

ansible-pull -i localhost, -U https://github.com/cekharchandra-devops/104-expense-ansible-roles-tf.git main.yaml -e environment=$environment -e component=$component