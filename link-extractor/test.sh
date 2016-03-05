#!/bin/bash

curl -X POST "http://localhost:3000/link" -H "Accept: application/json" -d '{ "url": "http://localhost/foobar" }'
