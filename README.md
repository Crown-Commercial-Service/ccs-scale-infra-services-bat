# ccs-scale-infra-services-bat

## SCALE Buy a Thing (BaT) Services

### Overview
This repository contains a complete set of configuration files and code to provision SCALE BAT services into the AWS cloud.  The infrastructure code is written in [Terraform](https://www.terraform.io/) and contains the following primary components:

### Prerequisites

The Spree database/es clusters must first be provisioned. This is done in project [ccs-scale-infra-db-bat](https://github.com/Crown-Commercial-Service/ccs-scale-infra-db-bat).

Check the README file for details of how to create the database.

### Pre install steps

1. Create an key pair instance called `{env}-spree-key'`

2. Create SSM Params

| System Parameter                        | Description |
| ----------------------------------------|-------------|
| /bat/{env}-rollbar-access-token         | token to send errors to rollbar |
| /bat/{env}-secret-key-base              | secret key for the spree app |
| /bat/{env}-basic-auth-username          | basic auth username for spree app and the client |
| /bat/{env}-basic-auth-password          | basic auth password for spree app and the client |
| /bar/{env}-basic-auth-enabled           | flag to enable/disable basic auth |
| /bat/{env}-session-cookie-secret        | client session cookie secret |
| /bat/{env}-products-import-bucket       | s3 bucket in which supplier import are progress |
| /bat/{env}-logit-hostname               | logit.io endpoint |
| /bat/{env}-logit-remote-port            | port to send logs to logit.io |
| /bat/{env}-suppliers-sftp-bucket        | S3 bucket which holds suppliers sftp buckets |
| /bat/{env}-sendgrid-api-key             | api key to sendgrid |
| /bat/{env}-logit-node                   | url to logit.io elasticsearch cluster |
| /bat/{env}-browser-rollbar-access-token | client side rollbar token |
| /bat/{env}-cnet-ftp-username            | username to cnet ftp site |
| /bat/{env}-cnet-ftp-password            | password to cnet ftp site |
| /bat/{env}-sidekiq-username             | can be any value - internal BaT use only |
| /bat/{env}-sidekiq-password             | can be any value - internal BaT use only |
| /bat/{env}-sendgrid-username            | username for sendgrid site |
| /bat/{env}-sendgrid-password            | password for sendgrid site |
| /bat/{env}-new-relic-license-key        | key from new relic site |
| /bat/{env}-ordnance-survey-api-token    | token to send request to the ordnance survey api |


3. Run `terraform apply`
 - This will provision the BaT service components

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
::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xaa.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xaa.txt')

::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xab.txt', names_path_name: 'https://cnet-spree-{env}staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xab.txt')

::Cnet::Import::ProductDocuments.call(path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content_Links-xac.txt', names_path_name: 'https://cnet-spree-{env}-staging.s3.eu-west-2.amazonaws.com/initial_import/digitalcontent/Digital_Content-xac.txt')
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
