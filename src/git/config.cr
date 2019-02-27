module Git
  class Config < C_Pointer
    def initialize(@value : LibGit::Config)
    end

    def initialize(path : String)
      nerr(LibGit.config_open_ondisk(out @value, path))
    end

    def self.global
      nerr(LibGit.config_open_default(out cfg))
      new(cfg)
    end

    def finalize
      LibGit.config_free(@value)
    end

    def snapshot
      LibGit.config_snapshot(out cfg, @value)
      Config.new(cfg)
    end

    @@entry_list = [] of String
    def get_all(key : String)
      @@entry_list = [] of String
      proc = -> (entry : LibGit::ConfigEntry*, payload : Void*) {
        @@entry_list << String.new(entry.value.value)
        return 0
      }
      err = LibGit.config_get_multivar_foreach(@value, key, nil, proc, Box.box(0))
      if err == 0
        return @@entry_list
      else
        return nil
      end
    end

    def get(key : String)
      self[key]
    end

    def [](key : String)
      buf = LibGit::Buf.new
      err = LibGit.config_get_string_buf(pointerof(buf), @value, key)
      if err == 0
        return String.new(buf.ptr)
      else
        return nil
      end
    end

    def []=(key : String, value : String|Bool|Int32)
      case value
      when String
        LibGit.config_set_string(@value, key, value)
      when Bool
        LibGit.config_set_bool(@value, key, value)
      when Int32
        LibGit.config_set_int32(@value, key, value)
      end
    end

    def transaction(&block)
      LibGit.config_lock(out tx, @value)
      begin
        yield
        LibGit.transaction_commit(tx)
      rescue
      ensure
        LibGit.transaction_free(tx)
      end
    end

    def delete(key : String)
      LibGit.config_delete_entry(@value, key)
    end
  end
end
