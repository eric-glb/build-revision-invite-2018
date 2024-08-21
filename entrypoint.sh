#!/usr/bin/env sh

if [ -e bin/no-invitation.zip ]; then
  nin run 8080
else 
  nin compile --no-closure-compiler --no-tracking && nin run 8080
fi
