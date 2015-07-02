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
  s.description = %q{The interface supports Account holder verifications, EFT payments, Debit orders, collecting statements.}

  s.rubyforge_project = "absa-h2h"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.executables   << 'absa-h2h'
  s.require_paths = ["lib"]
  
  s.add_dependency "activesupport"
  s.add_dependency "i18n"
  s.add_dependency "strata", "~> 0.0.1"

  s.add_development_dependency "rake", "0.9.2.2"
  s.add_development_dependency "rspec", "3.3.0"
end