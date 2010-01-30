$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'active_support'
require 'rtranslate'
require 'timer'
require 'yrb'

require 'idiom/base'
require 'idiom/yrb'
require 'idiom/yaml'