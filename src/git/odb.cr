module Git
  class ODB < C_Pointer
    @value : LibGit::Odb

    def finalize
      LibGit.odb_free(@value)
    end

    def self.get_type(type : String|Symbol|Nil) : LibGit::ObjectT
      type_str = type.to_s
      ret = LibGit::ObjectT::ObjectAny
      case type_str
      when "commit"
        ret = LibGit::ObjectT::ObjectCommit
      when "tag"
        ret = LibGit::ObjectT::ObjectTag
      when "blob"
        ret = LibGit::ObjectT::ObjectBlob
      when "tree"
        ret = LibGit::ObjectT::ObjectTree
      end
      return ret
    end
  end
end
