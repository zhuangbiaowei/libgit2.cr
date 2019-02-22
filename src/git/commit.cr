require "./object"

module Git

  alias HashSig = Hash(Symbol,String|Time|Int32)
  alias HashCommit = Hash(Symbol,String|Array(String)|Array(TreeEntryHash)|HashSig|Nil)

  class Signature < C_Value
    @value : LibGit::Signature 

    def name
      String.new(@value.name)
    end

    def email
      String.new(@value.email)
    end

    def epoch_time
      @value.when.time
    end

    def time
      Time.unix(epoch_time)
    end

    def time_offset
      @value.when.offset
    end

    def to_hash
      hash = HashSig.new
      hash[:name]=self.name
      hash[:email]=self.email
      hash[:time]=self.time
      hash[:time_offset]=self.time_offset
      return hash
    end

    def self.parse_data(hash : HashSig)
      sig = LibGit::Signature.new
      sig.name = hash[:name].to_s
      sig.email = hash[:email].to_s
      twhen = LibGit::Time.new
      twhen.time = hash[:time].as(Time).to_unix
      twhen.offset = hash[:time_offset].as(Int32)
      sig.when = twhen
      return sig
    end
  end

  class Commit < Object
    @value : LibGit::Commit

    def oid 
      sha
    end

    def sha
      oid = LibGit.commit_id(@value)
      p = LibGit.oid_tostr_s(oid)
      String.new(p)
    end

    def epoch_time
      LibGit.commit_time(@value)
    end

    def time
      Time.unix(epoch_time)
    end

    def author
      Signature.new(LibGit.commit_author(@value).value)
    end

    def committer
      Signature.new(LibGit.commit_committer(@value).value)
    end

    def message
      String.new(LibGit.commit_message(@value))
    end

    def parents
      parent_count.times.map { |i| parent(i) }.to_a
    end

    def parent_count
      LibGit.commit_parentcount(@value)
    end

    def tree
      nerr(LibGit.commit_tree(out t, @value))
      Tree.new(t)
    end

    def parent
      parent(0)
    end

    def parent(n : Int)
      nerr(LibGit.commit_parent(out parent, @value, n))
      Commit.new(parent)
    end

    def to_s(io)
      io << sha
    end

    def finalize
      LibGit.commit_free(@value)
    end

    def to_hash
      hash = HashCommit.new
      hash[:message]=self.message
      hash[:committer]=self.committer.to_hash
      hash[:author]=self.author.to_hash
      hash[:tree]=self.tree.oid.to_s
      hash[:parents]=self.parents.map{|i| i.to_s}
      return hash
    end

    def self.lookup(repo : Repo, oid : Oid)
      nerr(LibGit.commit_lookup(out commit, repo, oid.p))
      Commit.new(commit)
    end

    def self.lookup(repo : Repo, sha : String)
      if sha.size == 40
        self.lookup(repo, Git::Oid.new(sha))
      else
        nerr(LibGit.commit_lookup_prefix(out commit, repo, Git::Oid.new(sha).p, sha.size))
        Commit.new(commit)
      end
    end

    def self.parse_commit_data(repo : Repo, data : HashCommit)
      commit_data = LibGit::CommitData.new
      if data[:update_ref]?
        commit_data.update_ref = data[:update_ref].to_s
      else
        commit_data.update_ref = nil
      end
      commit_data.message = data[:message].to_s if data[:message]
      commit_data.committer = Signature.parse_data(data[:committer].as(HashSig)) if data[:committer]
      commit_data.author = Signature.parse_data(data[:author].as(HashSig)) if data[:author]
      commit_data.tree = Tree.parse_data(repo, data[:tree].to_s) if data[:tree]
      if data[:parents]
        parent_commits = Array(LibGit::Commit).new
        parents = data[:parents].as(Array(String))
        parents.each do |parent|
          #parent_commits << Commit.parse(parent)
        end
        commit_data.parents = parent_commits
        commit_data.parent_count = parent_commits.size
      end
      return commit_data
    end

    def self.parse(hash)
    end

    def self.create(repo : Repo, data : HashCommit)
      commit_data = self.parse_commit_data(repo, data)
      author = commit_data.author
      committer = commit_data.committer
      nerr(LibGit.commit_create(out id,
           repo.value,
           commit_data.update_ref,
           pointerof(author),
           pointerof(committer),
           nil,
           commit_data.message,
           commit_data.tree,
           commit_data.parent_count,
           commit_data.parents
           ))
      return String.new(LibGit.oid_tostr_s(pointerof(id)))
    end
  end
end
