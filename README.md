# paas-release-ci

This repository contains the scripts and Terraform configurations required to set up a Concourse pipeline for building Bosh releases. Releases each have their own repository and are stored in an S3 bucket when they are built.

It also includes pipelines for pushing applications to Cloud Foundry.

## Automatic build

There is a generic pipeline template for Bosh releases, and another for applications, which are pushed automatically by the [setup pipeline](pipelines/setup.yml).

For the Bosh releases, pull requests raised on their repository are automatically built by Concourse as dev releases. Merges to the master branch result in automatic building of a release which is semantically versioned in a way that distinguishes them from dev builds.

The `build` Concourse server is deployed in the CI account using its own Bosh. You can get information about the server using `make ci showenv` command. This will give you necessary information to log-in to the server.

## Requirements

* A running Concourse instance. Currently we use [paas-bootstrap](https://github.com/alphagov/paas-bootstrap) to set up an environment, which contains instructions in its README. But you can use any existing concourse instance by [overriding environment variables](#overriding-variables).
* CF CLI user credentials. This user is used to push apps to Cloud Foundry. For production apps (pushed from the build Concourse in CI) this user's credentials should already exist in the state bucket. They are persistently stored in `.paas-pass`.

## Setup

The instructions below are for CI, which is our persistent build environment. See the section below on dev environments if you are not deploying to CI.

* If the CF CLI user's credentials are not in the state S3 bucket, run `DEPLOY_ENV=build make ci upload-cf-cli-secrets` to upload them.
* Run `DEPLOY_ENV=build make ci pipelines`.
* The `setup` pipeline should auto-trigger and update all the pipelines.

A pipeline should be created for each Bosh release this repository is currently building releases for. The `build-dev-release` jobs should trigger when pull requests are raised against the Bosh release's repository. The `build-final-release` job should trigger when new commits are added to the branch used to build final releases.

### Dev environments

* Run `DEPLOY_ENV=... make dev upload-cf-cli-secrets`. You can override the credentials used by setting `CF_USER` and `CF_PASSWORD`.
* Run `CF_API=... DEPLOY_ENV=... make dev pipelines`, where `CF_API` is the URL of your dev Cloud Foundry API.
* The `setup` pipeline doesn't auto-trigger in Dev. Visit your running Concourse instance in a browser and trigger it manually,  or set the environment variable `ENABLE_AUTO_TRIGGER` to `true` at the previous step.

## Overriding variables

You can override some variables to customise the deployment:
 * `BRANCH` current branch to pull and use. e.g. `BRANCH=$(git rev-parse --abbrev-ref HEAD)`
 * `CONCOURSE_URL`, `CONCOURSE_ATC_PASSWORD`: to point to a different concourse with the given credentials.
 * `STATE_BUCKET_NAME`, `RELEASES_BUCKET_NAME`: use alternative state and releases buckets. Note that bucket for releases gets created in the `setup` pipeline. You have to thus chose a bucket name, that policy of the concourse you use allows creating. See our [bootstrap concourse bucket policy](https://github.gds/government-paas/aws-account-wide-terraform/blob/master/policies-json/concourse_manage_s3_buckets.json) for example. Also, if the bucket exists already, you'll have to remove it as creation would fail.
