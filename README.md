# ccs-scale-infra-services-bat

## SCALE Buy a Thing (BaT) Services

### Overview
This repository contains a complete set of configuration files and code to provision SCALE BAT services into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/) and contains the following primary components:

- TODO

### Prerequisites

TODO

### Pre install steps

1. Create IAM user called `spree-user` with policy (`app-policy`) allowing full access to S3 (TODO: this needs to be reviewed/tied down)
  - Add AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY valies to `spree.env`

2. Create an key pair instance called `{env}-spree-key'`

3. Create SSM Params
```
  /bat/{env}-rollbar-access-token
	/bat/{env}-secret-key-base
  /bat/{env}-basic-auth-username
  /bat/{env}-basic-auth-password
  /bat/{env}-db-password
  /bat/{env}-session-cookie-secret
```

4. Run `terraform apply`
 - It will provision everything, but not ECS - as key is missing - but will have enough to complete step 5 now
 - (this is just hack to work around this cyclic dependency - need a better solution)

5. Create `client.env` environment file

```
SPREE_API_HOST=http://{DOMAIN_NAME_OF_SPREE_SERVICE_LOAD_BALANCER}
SESSION_COOKIE_SECRET={RANDOM_STRING? NOT SURE}
```

6. Create `spree.env` environment file

```
SIDEKIQ_USERNAME={}
SIDEKIQ_PASSWORD={}
BUYER_UI_URL=https://{DOMAIN_NAME_OF_CLIENT_LOAD_BALANCER}
SENDGRID_USERNAME={}
SENDGRID_PASSWORD={}
APP_DOMAIN={DOMAIN_NAME_OF_SPREE_SERVICE_LOAD_BALANCER}
AWS_REGION=eu-west-2
AWS_ACCESS_KEY_ID={VALUE_FROM_IAM_USER_ABOVE}
AWS_SECRET_ACCESS_KEY={VALUE_FROM_IAM_USER_ABOVE}
S3_REGION=eu-west-2
S3_BUCKET_NAME=spree-${lower(var.environment)}-${lower(var.stage)}
ELASTICSEARCH_URL={URL_FOR_ELASTIC_SEARCH_PROVISIONED_IN_THESE_SCRIPTS}
```

7. Update the services
 - simple hack for this is to change the docker image to some random id - run `terraform apply`
 - then switch it to 'latest' again and rerun `terraform apply`
 - this whole part of the process needs review

NOTE/TODO: For steps 3 & 4 you have to provision the everything first to get the values to put into these files, so you then have to redploy the ECS Services - can we move these to environment variables rather than files (need to check with Sparks about this). There is also some duplication between env variables and file - is this necessary?

### Post install steps
When first building on a clean environment - the database will not be populated. To populate the database you need to connect to the docker container running in the relevant ECS/EC2 instance and execute a command

1. Check in ECS to find the correct EC2 instance for the `spree-app-task` (look at `EC2 instance id` property on the ECS service)

2. SSH to that instance

```
ssh -i  test.pem ec2-user@{IP}
```
Replace the ip with the one from Step 1 above

3. Get a terminal to the docker instance
```
 docker ps
```
Find the instance with IMAGE containing `spree-service-staging` and NAME containing `ecs-spree-app-task`

```
docker exec -it f0098e874593 /bin/bash
```
Replace the id with the one from `docker ps` above

4. Execute the command to populate the database

```
bundle exec rails db:seed
```

5. Reindex Elastic search

```
bundle exec rails searchkick:reindex:all
```

6. Add initial user to trusted domains
```

bundle exec rails console

#Add domain to scale_trusted_email_domain table
Scale::TrustedEmailDomain.create(name:'example.com')
#Get first user
user = Spree.user_class.first
#change state to active using update_columm  method to stop the after save callback running. i.e sending emails etc
user.update_column(:state, 'active')
#Confirm the update has worked.
user.reload
```
