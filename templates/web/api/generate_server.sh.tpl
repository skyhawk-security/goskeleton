#!/bin/bash

oapi-codegen -generate chi-server,types,spec -package server openapi.yaml > server.go