#!/usr/bin/env ruby
# See http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit.html
require 'test/unit'
base_path = File.expand_path(File.dirname(__FILE__))
require File.join(base_path, 'syntax_node_test')
require File.join(base_path, 'erb_document_test')
