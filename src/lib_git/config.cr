@[Link("git2")]
lib LibGit
  type Config = Void*
  alias ConfigForeachCb = (ConfigEntry*, Void* -> LibC::Int)
  struct ConfigEntry
    name : LibC::Char*
    value : LibC::Char*
    include_depth : LibC::UInt
    level : ConfigLevelT
    free : (ConfigEntry* -> Void)
    payload : Void*
  end
  enum ConfigLevelT
    ConfigLevelProgramdata = 1
    ConfigLevelSystem = 2
    ConfigLevelXdg = 3
    ConfigLevelGlobal = 4
    ConfigLevelLocal = 5
    ConfigLevelApp = 6
    ConfigHighestLevel = -1
  end

  fun repository_config = git_repository_config(out : Config*, repo : Repository) : LibC::Int
  fun config_free = git_config_free(cfg : Config)
  fun config_get_multivar_foreach = git_config_get_multivar_foreach(cfg : Config, name : LibC::Char*, regexp : LibC::Char*, callback : ConfigForeachCb, payload : Void*) : LibC::Int
  fun config_get_string_buf = git_config_get_string_buf(out : Buf*, cfg : Config, name : LibC::Char*) : LibC::Int
  fun config_open_default = git_config_open_default(out : Config*) : LibC::Int
  fun config_open_ondisk = git_config_open_ondisk(out : Config*, path : LibC::Char*) : LibC::Int
  fun config_set_int32 = git_config_set_int32(cfg : Config, name : LibC::Char*, value : Int32T) : LibC::Int
  fun config_set_bool = git_config_set_bool(cfg : Config, name : LibC::Char*, value : LibC::Int) : LibC::Int
  fun config_set_string = git_config_set_string(cfg : Config, name : LibC::Char*, value : LibC::Char*) : LibC::Int
  fun config_snapshot = git_config_snapshot(out : Config*, config : Config) : LibC::Int
end
