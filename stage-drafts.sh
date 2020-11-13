#!/bin/bash

hugo -D -d drafted
rsync -r drafted/ altre.us:drafts.blog.altre.us
ssh altre.us chown -R :www-data drafts.blog.altre.us \; chmod -R g+rX drafts.blog.altre.us
