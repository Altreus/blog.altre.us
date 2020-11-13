#!/bin/bash

hugo -d published
rsync -r published/ altre.us:blog.altre.us
ssh altre.us chown -R :www-data blog.altre.us \; chmod -R g+rX blog.altre.us
