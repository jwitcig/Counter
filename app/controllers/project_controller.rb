require 'git'
require 'project'
require 'swift'

GIT_REPO_DIR = 'git-repos'

class ProjectController < ApplicationController
  def list
    username = params[:username]
    project = Project::Project.new(username=params[:username], project_name=params[:project_name])

    @name = project.name

    Git.clone_if_needed(project, GIT_REPO_DIR)

    @swift_file_paths = Dir.glob("#{GIT_REPO_DIR}/#{project.name}/**/*.swift")
  end

  def stats
    @username = params[:username]
    project = Project::Project.new(username=params[:username],
                               project_name=params[:project_name])
    @project_name = project.name

    Git.clone_if_needed(project, GIT_REPO_DIR)

    file_paths = Dir.glob("#{GIT_REPO_DIR}/#{@project_name}/**/*.swift").sort_by(&:downcase)

    if file_paths.kind_of?(String)
      file_paths = [@file_paths]
    end

    swift_files = file_paths.map { |path| Swift::parse_file(path, project) }
                            .select { |file| !file.nil? }

    @number_of_swift_files = swift_files.count

    keywords = params[:keywords].nil? ? nil : params[:keywords].split(',')
    @individual_files_stats = swift_files.inject({}) { |compound_stats, file|
      stats = Swift::Stats.new(file)
      compound_stats[file] = {
           'import': stats.import_count,

            'class': stats.class_count,
         'protocol': stats.protocol_count,
        'extension': stats.extension_count,
           'struct': stats.struct_count,
             'enum': stats.enum_count,

              'let': stats.let_count,
              'var': stats.var_count,

         'IBOutlet': stats.iboutlet_count,
         'IBAction': stats.ibaction_count,

             'func': stats.func_count,

           'public': stats.public_count,
          'private': stats.private_count,
         'internal': stats.internal_count,
             'open': stats.open_count,
      }
      if !keywords.nil?
        compound_stats[file][keywords.join(' ')] = stats.count_of_types(keywords)
      end
      compound_stats
    }

    @combined_stats = @individual_files_stats.keys.inject({}) { |combined, file|
      @individual_files_stats[file].each do |key, count|
        combined[key] = combined[key].nil? ? count : combined[key] += count
      end
      combined
     }

    render template: 'project/files'
  end
end
