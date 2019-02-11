module Git
  class Index < C_Pointer
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
        :valid => (ie.flags & 0x8000)!=0,
        :stage => (ie.flags & 0x3000) >> 12
      }
    end
    def [](point : Int32)
      self.get_index_entry(LibGit.index_get_byindex(@value, point).value)
    end
    def [](path : String, stage = 0)
      self.get_index_entry(LibGit.index_get_bypath(@value, path, stage).value)
    end
    def conflicts?
      LibGit.index_has_conflicts(@value)==1
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
