#!/bin/sh
# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.

aws batch register-job-definition --cli-input-json file://jobdef.json  --profile genepattern



