# paas-release-ci

This repository contains the scripts and Terraform configurations required to set up a Concourse pipeline for building Bosh releases. Releases each have their own repository and are stored in an S3 bucket when they are built.


## Automatic build

All releases that have a [pipeline defined](scripts/build-boshrelease-pipelines.sh) in this repository, as well as PRs raised from a branch of these releases, are automatically built by `build concourse`. Releases on main branch get final release builds, whereas releases from PRs get development release build.

The `build concourse` server is deployed in CI account using its own BOSH. You can get information about the server using `make ci showenv` command. This will give you necessary information to log-in to the server.

## Requirements

* A running Concourse instance. Currently we use [paas-bootstrap](https://github.com/alphagov/paas-bootstrap) to set up an environment, which contains instructions in its README. But you can use any existing concourse instance by [overriding environment variables](#overriding-variables).

## Setup

* Run `make <env> pipelines`
* Visit your running Concourse instance in a browser and trigger the `setup` pipeline.

A pipeline should be created for each Bosh release this repository is currently building releases for. The `build-dev-release` jobs should trigger when pull requests are raised against the Bosh release's repository. The `build-final-release` job should trigger when new commits are added to the branch used to build final releases.

## Overriding variables

You can override some variables to customise the deployment:
 * `BRANCH` current branch to pull and use. e.g. `BRANCH=$(git rev-parse --abbrev-ref HEAD)`
 * `CONCOURSE_URL`, `CONCOURSE_ATC_PASSWORD`: to point to a different concourse with the given credentials.
 * `STATE_BUCKET_NAME`, `RELEASES_BUCKET_NAME`: use alternative state and releases buckets. Note that bucket for releases gets created in the `setup` pipeline. You have to thus chose a bucket name, that policy of the concourse you use allows creating. See our [bootstrap concourse bucket policy](https://github.gds/government-paas/aws-account-wide-terraform/blob/master/policies-json/concourse_manage_s3_buckets.json) for example. Also, if the bucket exists already, you'll have to remove it as creation would fail.
