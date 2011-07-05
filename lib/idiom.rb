$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'thread'
require 'rubygems'
require 'active_support'
require 'active_support/core_ext/hash'
require 'fileutils'
require 'rtranslate'
require 'timer'
require 'yrb'
require 'yaml'

require 'idiom/base'
require 'idiom/yrb'
require 'idiom/yaml'