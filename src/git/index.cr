module Git
  class Index < C_Pointer
    GIT_IDXENTRY_STAGEMASK = 0x3000
    GIT_IDXENTRY_VALID = 0x8000
    GIT_IDXENTRY_STAGESHIFT = 12

    @value : LibGit::Index
    def initialize(path : String)
      nerr(LibGit.index_open(out @value, path))
    end
    def initialize(@value : LibGit::Index)
    end
    def finalize
      LibGit.index_free(@value)
    end
    def each
      IndexIterator.new(@value)
    end
    def each(&block)
      ii = IndexIterator.new(@value)
      while true
        ie = ii.next
        if ie.class != Iterator::Stop
          yield ie
        else
          break
        end
      end
    end
    def count
      LibGit.index_entrycount(@value)
    end
    def clear
      LibGit.index_clear(@value)
    end
    def remove(path : String, stage = 0)
      LibGit.index_remove(@value, path, stage)
    end
    def remove_dir(path : String, stage = 0)
      LibGit.index_remove_directory(@value, path, stage)
    end
    alias HashEntry = Hash(Symbol, Bool | String | Time | UInt16 | UInt32)
    def sort(&block : HashEntry,HashEntry -> Int32) : Array(HashEntry)
      arr = Array(HashEntry).new
      ii = IndexIterator.new(@value)
      while true
        ie = ii.next
        if ie.class != Iterator::Stop
          arr << self.get_index_entry(ie.as(LibGit::IndexEntry))
        else
          break
        end
      end
      arr.sort &block
    end
    def get_index_entry(ie : LibGit::IndexEntry)
      path = String.new(ie.path)
      oid = Git::Oid.new(ie.id).to_s
      mtime = Time.unix(ie.mtime.seconds)
      ctime = Time.unix(ie.ctime.seconds)
      {
        :path => path,
        :oid => oid,
        :mtime => mtime,
        :ctime => ctime,
        :file_size => ie.file_size,
        :dev => ie.dev,
        :ino => ie.ino,
        :mode => ie.mode,
        :uid => ie.uid,
        :gid => ie.gid,
        :valid => (ie.flags & Index::GIT_IDXENTRY_VALID)!=0,
        :stage => (ie.flags & Index::GIT_IDXENTRY_STAGEMASK) >> Index::GIT_IDXENTRY_STAGESHIFT
      }
    end
    def to_index_entry(entry : HashEntry)
      index_entry = LibGit::IndexEntry.new
      index_entry.path = entry[:path].to_s.to_slice.to_unsafe
      index_entry.id = Git::Oid.new(entry[:oid].to_s)
      mt = LibGit::IndexTime.new
      mt.seconds = entry[:mtime].as(Time).to_unix
      mt.nanoseconds = mt.seconds * 1000
      index_entry.mtime = mt
      ct = LibGit::IndexTime.new
      ct.seconds = entry[:ctime].as(Time).to_unix
      ct.nanoseconds = ct.seconds * 1000
      index_entry.ctime = ct
      index_entry.file_size = entry[:file_size].as(UInt32)
      index_entry.dev = entry[:dev].as(UInt32)
      index_entry.ino = entry[:ino].as(UInt32)
      index_entry.mode = entry[:mode].as(UInt32)
      index_entry.uid = entry[:uid].as(UInt32)
      index_entry.gid = entry[:gid].as(UInt32)
      index_entry.flags = 0x0
      index_entry.flags_extended = 0x0
      if entry[:stage]?
        index_entry.flags &= ~Index::GIT_IDXENTRY_STAGEMASK
        index_entry.flags |= (entry[:stage].as(UInt32) << Index::GIT_IDXENTRY_STAGESHIFT) & Index::GIT_IDXENTRY_STAGEMASK
      end
      if entry[:valid]?
        index_entry.flags &= ~Index::GIT_IDXENTRY_VALID
        if entry[:valid]
          index_entry.flags |= Index::GIT_IDXENTRY_VALID
        end
      end
      return index_entry
    end
    def [](point : Int32)
      self.get_index_entry(LibGit.index_get_byindex(@value, point).value)
    end
    def [](path : String, stage = 0)
      self.get_index_entry(LibGit.index_get_bypath(@value, path, stage).value)
    end
    def get(point : Int32)
      self[point]
    end
    def get(path : String, stage = 0)
      self[path,stage]
    end
    def conflicts?
      LibGit.index_has_conflicts(@value)==1
    end
    def add(entry : HashEntry)
      ie = self.to_index_entry(entry)
      LibGit.index_add(@value, pointerof(ie))
    end
    def add(path : String)
      LibGit.index_add_bypath(@value, path)
    end
    def <<(entry : HashEntry)
      self.add(entry)
    end
    def write
      LibGit.index_write(@value)
    end
    def reload
      LibGit.index_read(@value, 0)
    end
  end

  class IndexIterator < NoError
    include Enumerable(LibGit::IndexEntry)
    include Iterator(LibGit::IndexEntry)
    @value : LibGit::Index

    def initialize(@value : LibGit::Index)
      nerr(LibGit.index_iterator_new(out @iter, @value))
    end
    def next
      r = LibGit.index_iterator_next(out idx, @iter)
      if r == LibGit::ErrorCode::Iterover.value
        stop
      else
        nerr(r)
        return idx.as(Pointer(LibGit::IndexEntry)).value
      end
    end
    def finalize
      LibGit.index_iterator_free(@iter)
    end
    def count
      LibGit.index_entrycount(@value)
    end
  end
end
