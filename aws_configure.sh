#!/bin/bash
AWS_ACCESS_KEY=AKIARUJTUIQAP6BBPWOP
AWS_SECRET=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
REGION=us-east-1
aws configure set aws_access_key_id $AWS_ACCESS_KEY;
aws configure set aws_secret_access_key $AWS_SECRET;
aws configure set region $REGION;
