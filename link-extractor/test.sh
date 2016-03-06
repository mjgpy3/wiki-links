#!/bin/bash

curl -X POST "http://localhost:3000/link" -H "Accept: application/json" -d '{ "url": "https://en.wikipedia.org/wiki/Sonic_the_Hedgehog" }'
