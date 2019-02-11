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
      LibGit.odb_free(odb)
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

    def initialize(@path : String, options : Hash(Symbol,Array(String)))
      nerr(LibGit.repository_open(out @value, @path), "Couldn't open repository at #{path}")
      if options[:alternates]
        LibGit.repository_odb(out odb, @value)
        options[:alternates].each do |path|
          nerr(LibGit.odb_add_disk_alternate(odb, path))
        end
      end
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

    def merge_base(*args)
      len = args.size
      raise "wrong number of arguments (#{len} for 2+)" if len<2
      input_array = args.map {|id| self.get_oid(id)}.to_a
      LibGit.merge_base_many(out base, @value, len, input_array.to_unsafe)
      return String.new(LibGit.oid_tostr_s(pointerof(base)))
    end

    def merge_bases(*args)
      len = args.size
      raise "wrong number of arguments (#{len} for 2+)" if len<2
      input_array = args.map {|id| self.get_oid(id)}.to_a
      LibGit.merge_bases_many(out bases, @value, len, input_array.to_unsafe)
      ids = Slice(LibGit::Oid).new(bases.ids, bases.count).to_a
      return ids.map { |id| String.new(LibGit.oid_tostr_s(pointerof(id)))}
    end

    def get_oid(id) : LibGit::Oid
      oid = LibGit::Oid.new
      if id.class == String
        id = id.to_s
        if self.is_id(id)
          LibGit.oid_fromstr(pointerof(oid), id)
        else
          ref = self.ref(id)
          LibGit.oid_fromstr(pointerof(oid), ref.oid)
        end
      else
        if id.class == Git::Commit
          LibGit.oid_fromstr(pointerof(oid), id.to_s)
        end
      end
      return oid
    end

    def is_id(id : String) : Bool
      ret = false
      if md = id.match(/[0-9a-f]*/)
        ret = id.size == md[0].size
      end
      return ret
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

    def ahead_behind(local, upstream)
      local_id = self.get_oid(local)
      upstream_id = self.get_oid(upstream)
      LibGit.graph_ahead_behind(out ahead, out behind, self, pointerof(local_id), pointerof(upstream_id))
      return ahead, behind 
    end

    def expand_oids(ids : Array(String), type : String|Symbol = "")
      if type.to_s == ""
        return self.expand_oids(ids, [""], true)
      else
        return self.expand_oids(ids, [type], true)
      end
    end

    def expand_oids(ids : Array(String), types : Array(String|Symbol), is_single = false)
      expand_count = ids.size
      if types.size != expand_count && is_single == false
        raise Error.new(0,"the `object_type` array must be the same length as the `oids` array")
      end

      expand = Array(LibGit::OdbExpandId).new
      expand_count.times do |i|
        oid = LibGit::OdbExpandId.new
        oid.id = self.get_oid(ids[i])
        oid.length = ids[i].size
        if types.empty?
          oid.type = LibGit::ObjectT::ObjectAny
        elsif types.size == 1
          otype = Git::ODB.get_type(types.first?)
          oid.type = otype
        else
          oid.type = Git::ODB.get_type(types[i].to_s)
        end
        expand << oid
      end

      LibGit.repository_odb(out odb, @value)
      LibGit.odb_expand_ids(odb, expand.to_unsafe, expand_count)
      ret = Hash(String, String).new
      expand_count.times do |i|
        if expand[i].length == 40
          begin
            ret[ids[i]] = Git::Oid.new(expand[i].id).to_s
          rescue
          end
        end
      end
      return ret
    end

    def descendant_of?(commit : String|Git::Object, ancestor : String|Git::Object)
      commit_oid = self.get_oid(commit)
      ancestor_oid = self.get_oid(ancestor)
      self.lookup_commit Git::Oid.new(commit_oid)
      self.lookup_commit Git::Oid.new(ancestor_oid)
      return LibGit.graph_descendant_of(@value, pointerof(commit_oid), pointerof(ancestor_oid)) == 1
    end
  end
end
