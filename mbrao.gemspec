# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require File.expand_path('../lib/mbrao/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "mbrao"
  gem.version = Mbrao::Version::STRING
  gem.homepage = "http://github.com/ShogunPanda/mbrao"
  gem.summary = "A pipelined content parser with metadata support."
  gem.description = "A pipelined content parser with metadata support."
  gem.rubyforge_project = "mbrao"

  gem.authors = ["Shogun"]
  gem.email = ["shogun_panda@me.com"]

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_dependency("lazier", "~> 2.6.5")
  gem.add_dependency("html-pipeline", "~> 0.0.8")
  gem.add_dependency("slim", "~> 1.3.6")
end