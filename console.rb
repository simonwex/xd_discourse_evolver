#!/usr/bin/env ruby

require 'pp'
require_relative 'lib/api'

client = get_client

require 'ripl'
Ripl.start :binding => binding
