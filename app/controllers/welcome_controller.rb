require 'project'
require 'swift'
require 'git'

class WelcomeController < ApplicationController
  def index
    username = 'jwitcig'
    project = Project::Project.new(name='Popper')

    @name = project.name
  end
end


# Dir.glob('**/*.swift') do |swift_file|
#   puts swift_file
# end
