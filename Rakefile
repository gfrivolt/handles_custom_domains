#encoding: utf-8
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
end
#encoding: utf-8
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "handles_custom_domains"
    gem.summary = %Q{Simple tool for defining actions based on the incoming request.}
    gem.description = %Q{Define strategies for handling requests coming from clients. It enables to act on requests on the model level.}
    gem.email = "fifigyuri@gmail.com"
    gem.homepage = "http://github.com/fifigyuri/handles_custom_domains"
    gem.authors = ["György Frivolt"]

    gem.add_development_dependency "rspec", '~> 2.5.0'
    gem.add_development_dependency "factory_girl"
    gem.add_development_dependency "faker"
    gem.add_development_dependency "thoughtbot-shoulda", "~> 2.11.1"
    gem.add_development_dependency "ruby-debug19"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
end

task :default => :spec

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "handles_custom_domains #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
