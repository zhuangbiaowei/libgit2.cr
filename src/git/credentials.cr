module Git
  module Credentials
    class UserPassword
      @username : String
      @password : String
      def initialize(options : NamedTuple(username: String, password: String))
        @username, @password = options[:username], options[:password]
      end

      def username
        @username
      end

      def password
        @password
      end
    end
  end
end