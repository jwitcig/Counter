module Git
  def clone(project, destination)
    system "git clone #{project.url} #{destination}/#{project.name}"
  end

  def project_exists(project, directory)
    return File.directory?("#{directory}/#{project.name}")
  end

  def clone_if_needed(project, destination)
    if !project_exists(project, destination)
      clone(project, destination)
    end
  end

  module_function :clone, :project_exists, :clone_if_needed
end
