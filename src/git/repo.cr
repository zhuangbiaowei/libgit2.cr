module Git
  alias Repo = Repository
  
  struct OdbObject
    property type, len, data
    def initialize(@type : Symbol, @len : UInt64, @data : String)
    end
  end

  class Repository < C_Pointer
    @value : LibGit::Repository
    getter :path

    @object_types = {
      LibGit::ObjectT::ObjectAny => :any,
      LibGit::ObjectT::ObjectBad => :bad,
      LibGit::ObjectT::ObjectCommit => :commit,
      LibGit::ObjectT::ObjectTree => :tree,
      LibGit::ObjectT::ObjectBlob => :blob,
      LibGit::ObjectT::ObjectTag => :tag
    }

    def read(hex)
      LibGit.repository_odb(out odb, @value)
      nerr(LibGit.oid_fromstrn(out oid, hex, hex.size))
      nerr(LibGit.odb_read(out obj, odb, pointerof(oid)))
      obj_type = @object_types[LibGit.odb_object_type(obj)]
      obj_len = LibGit.odb_object_size(obj)
      object = OdbObject.new(obj_type, obj_len, String.new(LibGit.odb_object_data(obj).as(UInt8*), obj_len))
      LibGit.odb_object_free(obj)
      return object
    end

    def read_header(hex)
      LibGit.repository_odb(out odb, @value)
      nerr(LibGit.oid_fromstrn(out oid, hex, hex.size))
      nerr(LibGit.odb_read(out obj, odb, pointerof(oid)))
      obj_type = @object_types[LibGit.odb_object_type(obj)]
      obj_len = LibGit.odb_object_size(obj)
      LibGit.odb_object_free(obj)
      hash = Hash(Symbol, Symbol|UInt64).new
      hash[:type] = obj_type
      hash[:len] = obj_len
      return hash
    end

    def inspect
    end

    def checkout(target, options = {} of Symbol=>Symbol)
    end

    def status(file = nil, &block)
    end

    def diff(left, right, opt = {} of Symbol=>Symbol)
    end

    def diff_workdir(left, opts = {} of Symbol=>Symbol)
    end

    def rev_parse(spec)
    end

    def rev_parse_oid(spec)
    end

    def remotes
      RemoteCollection.new(self)
    end

    def submodules
    end

    def create_branch(name, sha_or_ref = "HEAD")
    end

    def blob_at(revision, path)
      tree = Git::Commit.lookup(self, revision).tree
      begin
        blob_data = tree.path(path)
      rescue Git::Error
        return nil
      end
      blob = Git::Blob.lookup(self, blob_data[:oid])
      return blob
    end

    def fetch(remote_or_url, *args)
    end

    def push(remote_or_url, *args)
    end

    def initialize(@path : String)
      nerr(LibGit.repository_open(out @value, @path), "Couldn't open repository at #{path}")
    end

    def initialize(@value : LibGit::Repository, @path : String)
    end

    def self.open(path : String)
      nerr(LibGit.repository_open(out repo, path), "Couldn't open repository at #{path}")
      new(repo, path)
    end

    # bare
    # init_at
    # discover
    # clone_at

    def self.init_at(path, is_bare = false)
      LibGit.repository_init(out repo, path, is_bare ? 1 : 0)
      new(repo, path)
    end

    def exists?(oid : Oid)
      nerr(LibGit.repository_odb(out odb, @value))
      err = LibGit.odb_exists(odb, oid.p)
      LibGit.odb_free(odb)

      err == 1
    end

    def exists?(sha : String)
      exists?(Git::Oid.new(sha))
    end

    # path
    # workdir
    # workdir=

    def bare? : Bool
      LibGit.repository_is_bare(@value) == 1
    end

    # shallow?
    # empty?

    # head_detached?
    # head_unborn?

    def head
      nerr(LibGit.repository_head(out ref, @value))
      if !ref.null?
        Reference.new(ref)
      else
        raise "error"
      end
    end

    def head=(head : String)
      nerr(LibGit.repository_set_head(@value, head))
    end

    def head?
      nerr(LibGit.repository_head(out ref, @value))
      if !ref.null?
        Reference.new(ref)
      end
    end

    def last_commit
      head
    end

    @@oid_array = [] of String
    def each_id
      @@oid_array = [] of String
      nerr(LibGit.repository_odb(out odb, @value))
      proc = -> (oid : LibGit::Oid*, payload : Void*) {
        @@oid_array << String.new(LibGit.oid_tostr_s(oid))
        return 0
      }
      nerr(LibGit.odb_foreach(odb, proc, Box.box(0)))
      LibGit.odb_free(odb)
      return @@oid_array
    end

    def each_id(&block)
      self.each_id.each do |oid|
        yield oid
      end
    end

    def lookup(sha : String)
      Object.lookup(self, sha)
    end

    def lookup_commit(oid : Oid)
      nerr(LibGit.commit_lookup(out commit, @value, oid.p))
      Commit.new(commit)
    end

    def lookup_commit(sha : String)
      lookup_commit(Git::Oid.new(sha))
    end

    def lookup_tag(oid : Oid)
      nerr(LibGit.tag_lookup(out tag, @value, oid.p))
      Tag.new(tag)
    end

    def lookup_tag(sha : String)
      lookup_tag(Git::Oid.new(sha))
    end

    def lookup_tree(oid : Oid)
      nerr(LibGit.tree_lookup(out tree, @value, oid.p))
      Tree.new(tree)
    end

    def lookup_tree(sha : String)
      lookup_tree(Git::Oid.new(sha))
    end

    def lookup_blob(oid : Oid)
      nerr(LibGit.blob_lookup(out blob, @value, oid.p))
      Blob.new(blob)
    end

    def lookup_blob(sha : String)
      lookup_blob(Git::Oid.new(sha))
    end

    def branches
      BranchCollection.new(self)
    end

    def ref(name : String)
      nerr(LibGit.reference_lookup(out ref, @value, name))
      Reference.new(ref)
    end

    def refs
      ReferenceCollection.new(self)
    end

    def references
      refs
    end

    def refs(glob : String)
      ReferenceCollection.new(self).each(glob)
    end

    def ref_names
      names = [] of String
      refs.each { |ref| names << ref.name }
      return names
    end

    def tags
      TagCollection.new(self)
    end

    def tags(glob : String)
      TagCollection.new(self).each(glob)
    end

    def walk(from : String | Oid, sorting : Sort = Sort::Time, &block)
      walk(from, sorting).each { |c| yield c }
    end

    def walk(from : String | Oid, sorting : Sort = Sort::Time)
      walker = RevWalk.new(self)
      walker.sorting(sorting)
      walker.push(from)
      walker
    end

    def blame
    end

    def finalize
      LibGit.repository_free(@value)
    end
  end
end
