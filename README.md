# ccs-scale-infra-services-bat

## SCALE Buy a Thing (BaT) Services

### Overview
This repository contains a complete set of configuration files and code to provision SCALE BAT services into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/) and contains the following primary components:

- TODO

### Prerequisites

TODO

### Post install steps
When first building on a clean environment - the database will not be populated. To populate the database you need to connect to the docker container running in the relevant ECS/EC2 instance and execute a command

1. Check in ECS to find the correct EC2 instance for the `spree-app-task`

2. SSH to that instance

```
ssh -i  test.pem ec2-user@3.8.115.224
```
Replace the ip with the one from Step 1 above

3. Get a terminal to the docker instance
```
 docker ps
```
Find the instance `spree-service-staging`

```
docker exec -it f0098e874593 /bin/bash
```
Replace the id with the one from `docker ps` above

4. Execute the command to populate the database

```
bundle exec rails db:seed
```

5. Add initial user to trusted domains
```
#Add domain to scae_trusted_email_domain table
Scale::TrustedEmailDomain.create(name:'example.com')
#Get first user
user = Spree.user_class.first
#change state to active using update_columm  method to stop the after save callback running. i.e sending emails etc
user.update_column(:state, 'active')
#Confirm the update has worked.
user.reload! (edited) 
```
