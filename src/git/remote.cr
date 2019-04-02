module Git

  class Remote < C_Pointer
    @value : LibGit::Remote

    def initialize(@value)
    end

    def name
      String.new(LibGit.remote_name(@value))
    end

    def finalize
      LibGit.remote_free(@value)
    end

    def ls
        ls_data = Array(Hash(Symbol, String|Bool|Nil)).new
        custom_headers = LibGit::Strarray.new
        err = LibGit.remote_connect(@value, LibGit::Direction::DirectionFetch, nil, nil, pointerof(custom_headers))
        if err==0
          len = 0_u64
          err = LibGit.remote_ls(out p_heads, pointerof(len), @value)
          if err == 0
            len.times do |i|
              head = (p_heads+i).value.value
              head_hash = Hash(Symbol, String|Bool|Nil).new
              head_hash[:local?] = head.local==1
              head_hash[:oid] = Git::Oid.new(head.oid).to_s
              head_hash[:loid] = Git::Oid.new(head.loid).to_s
              head_hash[:loid] = nil if head_hash[:loid] == "0"*40
              head_hash[:name] =  String.new(head.name)
              ls_data << head_hash
            end
            LibGit.remote_disconnect(@value)
            return ls_data
          end
        end
        LibGit.remote_disconnect(@value)
    end

    def check_connection(direction : Symbol)
        if direction == :fetch
          direction_val = LibGit::Direction::DirectionFetch
        elsif direction == :push
          direction_val = LibGit::Direction::DirectionPush
        else
          return false
        end
        custom_headers = LibGit::Strarray.new
        err = LibGit.remote_connect(@value, direction_val, nil, nil, pointerof(custom_headers))
        return err == 0
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

    def [](name)
      if @keys.includes?(name)
        LibGit.remote_lookup(out remote, @repo, name)
        return Remote.new(remote)
      else
        return nil
      end
    end

    def create_anonymous(url : String)
      LibGit.remote_create_anonymous(out remote, @repo, url)
      return Remote.new(remote)
    end

    def size
      @keys.size
    end
  end
end
