# ccs-scale-infra-services-bat

## SCALE Buy a Thing (BaT) Services

### Overview
This repository contains a complete set of configuration files and code to provision SCALE BAT services into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/) and contains the following primary components:

### Prerequisites

The Spree database/es clusters must first be provisioned. This is done in project [ccs-scale-infra-db-bat](https://github.com/Crown-Commercial-Service/ccs-scale-infra-db-bat).

Check the README file for details of how to create the database.

### Pre install steps

1. Create IAM user called `spree-user` with policy (`app-policy`) allowing full access to S3 (TODO: this needs to be reviewed/tied down)
  - Add AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY values to `spree.env`

2. Create an key pair instance called `{env}-spree-key'`

3. Create SSM Params
```
  /bat/{env}-rollbar-access-token
	/bat/{env}-secret-key-base
  /bat/{env}-basic-auth-username
  /bat/{env}-basic-auth-password
  /bar/{env}-basic-auth-enabled
  /bat/{env}-session-cookie-secret
  /bat/{env}-products-import-bucket
  /bat/{env}-logit-hostname
  /bat/{env}-logit-remote-port
  /bat/{env}-suppliers-sftp-bucket
  /bat/{env}-documents-terms-and-conditions-url
```

4. Run `terraform apply`
 - It will provision everything, but not ECS - as key is missing - but will have enough to complete step 5 now
 - (this is just hack to work around this cyclic dependency - need a better solution)

5. Create `client.env` environment file

```
SESSION_COOKIE_SECRET={RANDOM_STRING? NOT SURE}
DOCUMENTS_TERMS_AND_CONDITIONS_URL=https://purchasingplatform.crowncommercial.gov.uk/
```

6. Create `spree.env` environment file

```
SIDEKIQ_USERNAME={}
SIDEKIQ_PASSWORD={}
SENDGRID_USERNAME={}
SENDGRID_PASSWORD={}
AWS_REGION=eu-west-2
AWS_ACCESS_KEY_ID={VALUE_FROM_IAM_USER_ABOVE}
AWS_SECRET_ACCESS_KEY={VALUE_FROM_IAM_USER_ABOVE}
S3_REGION=eu-west-2
S3_BUCKET_NAME=spree-${lower(var.environment)}-${lower(var.stage)}
```

7. Upload `client.env` and `spree.env` to the provisioned S3 bucket `system-spree-[env]-staging`

8. Update the services
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

4. Update Email 'from' address
```
bundle exec rails console

#Update 'from' address
store = Spree::Store.first
store.mail_from_address= '<<NEEDS TO MATCH SENDGRID USERNAME>>'
store.save

#Clear the cache
rake cache:clear
```

5. Execute the command to populate the database

```
bundle exec rails db:seed
```

6. Reindex Elastic search

```
bundle exec rails searchkick:reindex:all
```

7. Add initial user to trusted domains
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

8. Ensure that `cnet-spree-{env}-staging` bucket is seeded with Cnet data

TODO: Currently this is achieved by copying the `/initial_import` folder from the equivalent S3 bucket in an existing environment. We need to understand where this data comes from in the event it needed to be populated from scratch. Also may be worth exploring the possibility of having a single central store for this (e.g. in Management account), as it is several GBs in size.

Create the following folder structure in the `cnet-spree-{env}-staging` bucket

```
initial_import/
nightly_updates/
  - done/
  - error/
  - new/
  - processing/
```

9. Seed Cnet data

Manufacturers - all

```
::Cnet::Import::Manufacturers.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/metamap/Distivoc.txt')
```

Categories - all

```
::Cnet::Import::Categories.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/categorization/Cct_Categories.txt')
```

Products - 50k
```
::Cnet::Import::Products.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/catalog/prod-xaa.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/stdnee-xaa.txt')

::Cnet::Import::Products.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/catalog/prod-xab.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/stdnee-xab.txt')

::Cnet::Import::Products.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/catalog/prod-xac.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/stdnee-xac.txt')

```
Product Documents - 50k
```
::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xaa.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.co
m/initial_import/digitalcontent/Digital_Content-xaa.txt')

::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xab.txt', names_path_name: 'https://cnet-spree-{env}staging.s3.eu-west-2.amazonaws.co
m/initial_import/digitalcontent/Digital_Content-xab.txt')

::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xac.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.co
m/initial_import/digitalcontent/Digital_Content-xac.txt')
```

Product Xmls - 50k
```
::Cnet::Import::ProductXmls.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xaa.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xaa.txt')

::Cnet::Import::ProductXmls.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xab.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xab.txt')

::Cnet::Import::ProductXmls.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xac.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xac.txt')

```
Products Categories - 50k
```
::Cnet::Import::ProductCategories.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/categorization/Cct_Products-xaa.txt')

::Cnet::Import::ProductCategories.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/categorization/Cct_Products-xab.txt')

::Cnet::Import::ProductCategories.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/categorization/Cct_Products-xac.txt')
```

Product Properties - 50k
```
::Cnet::Import::ProductProperties.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/especee-xaa.txt', names_path_name: 'https://cnet-spree-s{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/evocee.txt')

::Cnet::Import::ProductProperties.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/especee-xab.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/evocee.txt')

::Cnet::Import::ProductProperties.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/especee-xac.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/components/evocee.txt')
```

Products Images - 50k - (Images is still being worked on, though. It works, we just limiting number of duplicated images or image placeholders)
```
::Cnet::Import::ProductImages.call(
  path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xaa.txt',
  image_data_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xaa.txt',
  attributes_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta-xaa.txt',
  attributes_dictionary_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta_Value_Voc-xaa.txt')

::Cnet::Import::ProductImages.call(
  path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xab.txt',
  image_data_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xab.txt',
  attributes_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta-xaa.txt',
  attributes_dictionary_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta_Value_Voc-xab.txt')

::Cnet::Import::ProductImages.call(
  path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xab.txt',
  image_data_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xab.txt',
  attributes_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta-xab.txt',
  attributes_dictionary_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Meta_Value_Voc-xab.txt')
```

After importing CNET data you will need to reindex Elastic search again

```
bundle exec rails searchkick:reindex:all
```

Set up product catalogue directory structure

Go to the following S3 bucket spree-{env}-product-import

- create folder called `imports`
- inside the `imports` folder create the following folders
```
  - done
  - error
  - new
  - processing
```
