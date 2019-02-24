module Git
  class Config < C_Pointer
    def initialize(@value : LibGit::Config)
    end
    def finalize
      LibGit.config_free(@value)
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
  end
end
