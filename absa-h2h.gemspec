# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "absa-h2h/version"

Gem::Specification.new do |s|
  s.name        = "absa-h2h"
  s.version     = Absa::H2h::VERSION
  s.authors     = ["Jeffrey van Aswegen, Douglas Anderson"]
  s.email       = ["jeffmess@gmail.com, i.am.douglas.anderson@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A ruby interface to commumicate with the ABSA Host 2 Host platform}
  s.description = %q{TODO: }

  s.rubyforge_project = "absa-h2h"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
