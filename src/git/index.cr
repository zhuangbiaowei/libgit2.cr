module Git
  class Index < C_Pointer
    @value : LibGit::Index
    getter :path
    def initialize(@path : String)
      nerr(LibGit.index_open(out @value, @path))
    end
    def initializa(@value : Index)
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
