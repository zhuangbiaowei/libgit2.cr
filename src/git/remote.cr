module Git

  class Remote < C_Pointer
    @value : LibGit::Remote

    def name
      String.new(LibGit.remote_name(@value))
    end

    def finalize
      LibGit.remote_free(@value)
    end
  end

  class RemoteCollection < NoError
    include Enumerable(Remote)
    include Iterable(Remote)
    @keys : Array(String)

    def initialize(@repo : Repo)
      nerr(LibGit.remote_list(out arr, @repo))
      @keys = arr.count.times.map { |i| String.new(arr.strings[i]) }.to_a
      LibGit.strarray_free(pointerof(arr))
    end

    def each
    end

    def size
      @keys.size
    end
  end
end
