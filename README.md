# paas-release-ci

This repository contains the scripts and Terraform configurations required to set up Concourse pipelines for:

* building Bosh releases
* running integration tests
* deploying apps to Cloud Foundry

Apps that are part of running or operating Cloud Foundry itself should be deployed via [paas-cf](https://github.com/alphagov/paas-cf/).

There is a generic pipeline template for building Bosh releases, running integration tests, and deploying applications, which are pushed automatically by the [setup pipeline](pipelines/setup.yml).

For the Bosh releases, pull requests raised on their repository are automatically built by Concourse as dev releases. Merges to the master branch result in automatic building of a release which is semantically versioned in a way that distinguishes them from dev builds.


## Setup

### Create Concourse

Create an environment using the [paas-bootstrap repository](https://github.com/alphagov/paas-bootstrap), which contains instructions in its README. But you can use any existing concourse instance by [overriding environment variables](#overriding-variables).

### Upload Secrets

This repository defines `make` targets for uploading three types of credentials to the S3 state bucket prior to configuring pipelines:

* CF CLI: this user is used to push apps to Cloud Foundry. For production apps (pushed from the build Concourse in CI) this user's credentials should already exist in the state bucket.

  ```
  DEPLOY_ENV=build make ci upload-cf-cli-secrets
  ```

* Compose API key: this is for the integration tests to use the real Compose API.

  ```
  DEPLOY_ENV=build make ci upload-compose-secrets
  ```

* DeskPro API key: this is to enable the paas-product-page app to create tickets via the DeskPro API.

  ```
  DEPLOY_ENV=build make ci upload-deskpro-secrets
  ```

All three sets of credentials are stored in [paas-credentials](https://github.com/alphagov/paas-credentials).

### Push Pipelines

The instructions below are for CI, which is our persistent build environment. See the section below on dev environments if you are not deploying to CI.

* Run `DEPLOY_ENV=build make ci pipelines`.
* The `setup` pipeline should auto-trigger and update all the pipelines.

A pipeline should be created for each Bosh release this repository is currently building releases for. The `build-dev-release` jobs should trigger when pull requests are raised against the Bosh release's repository. The `build-final-release` job should trigger when new commits are added to the branch used to build final releases.

### Dev environments

When you setup the pipelines in a dev environment they will be paused by default. You can manaully unpause the ones that you need to work on, but be aware that they will submit their results to GitHub pull requests.

* Run `DEPLOY_ENV=... make dev upload-cf-cli-secrets`. You can override the credentials used by setting `CF_USER` and `CF_PASSWORD`.
* Run `CF_API=... DEPLOY_ENV=... make dev pipelines`, where `CF_API` is the URL of your dev Cloud Foundry API.
* Run the setup pipeline.
* Based on our current configuration your dev build CI will not be allowed to access your dev CloudFoundry API. This means you will have to manually allow the traffic in the AWS console.


## Overriding variables

You can override some variables to customise the deployment:
 * `BRANCH` current branch to pull and use. e.g. `BRANCH=$(git rev-parse --abbrev-ref HEAD)`
 * `CONCOURSE_URL`, `CONCOURSE_ATC_PASSWORD`: to point to a different concourse with the given credentials.
 * `STATE_BUCKET_NAME`, `RELEASES_BUCKET_NAME`, `RELEASES_BLOBS_BUCKET_NAME`: use alternative state and releases buckets. Note that buckets for releases get created in the `setup` pipeline. You have to thus chose a bucket name, that policy of the concourse you use allows creating. See our [bootstrap concourse bucket policy](https://github.digital.cabinet-office.gov.uk/government-paas/aws-account-wide-terraform/blob/master/policies-json/concourse_manage_s3_buckets.json) for example. Also, if the bucket exists already, you'll have to remove it as creation would fail.

## Accessing Concourse

The `build` Concourse server is deployed in the CI account using its own Bosh. You can get information about the server using `make ci showenv` command. This will give you necessary information to log-in to the server.
