# paas-release-ci

This repository contains the scripts and Terraform configurations required to set up a Concourse pipeline for building Bosh releases. Releases each have their own repository and are stored in an S3 bucket when they are built.

## Requirements

* A running Concourse instance. Currently we use [paas-bootstrap](https://github.com/alphagov/paas-bootstrap) to set up an environment, which contains instructions in its README.

## Setup

* Run `make <env> pipelines`
* Visit your running Concourse instance in a browser and trigger the `setup` pipeline.

A pipeline should be created for each Bosh release this repository is currently building releases for. The `build-dev-release` jobs should trigger when pull requests are raised against the Bosh release's repository. The `build-final-release` job should trigger when new commits are added to the branch used to build final releases.

