module FixtureRepo
  def self.from_libgit2(name, *args) : Git::Repository
    return Git::Repository.init_at(name)
  end
end
