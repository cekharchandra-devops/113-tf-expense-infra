# ingress rules for expense infra

![alt text](expense-infra-sg.drawio.svg)


* mysql instance should allow connetion from instances which are attacched to backend sg on port 3306
* backend instance should allow connetion from instances which are attacched to frontend sg on port 8080
* frontend instance should allow connetion from cidr block "0.0.0.0/0" port 80
* mysql, backend, frontend instances should allow connetion from instances which are attacched to bastion sg and ansible sg on port 22