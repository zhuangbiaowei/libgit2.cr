require "file_utils"

module FixtureRepo
  def self.from_libgit2(name, *args) : Git::Repository
    path = "./test/git-#{name}"
    FileUtils.rm_r(path) if Dir.exists?(path)
    FileUtils.cp_r("./test/fixtures/#{name}", path)
    prepare(path)
    return Git::Repository.open(path)
  end

  def self.empty
    path = "./test/test-empty"
    `rm -rf #{path}` if Dir.exists?(path)
    repo = Git::Repository.init_at(path)
  end

  def self.prepare(path)
    Dir.cd(path) do
      File.rename(".gitted", ".git") if File.exists?(".gitted")
      File.rename("gitattributes", ".gitattributes") if File.exists?("gitattributes")
      File.rename("gitignore", ".gitignore") if File.exists?("gitignore")
    end
  end
end
