#!/usr/bin/env groovy

import groovy.json.JsonSlurper

def slurper = new JsonSlurper()

def releases = slurper.parseText('https://api.adoptium.net/v3/info/available_releases'.toURL().text)

println releases.available_lts_releases