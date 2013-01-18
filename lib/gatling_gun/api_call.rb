class GatlingGun
  class ApiCall
    BASE_URL = "https://sendgrid.com/api"
    CA_PATH  = File.join(File.dirname(__FILE__), *%w[.. .. data ca-bundle.crt])
    
    def initialize(action, parameters)
      @action     = action
      @parameters = parameters
    end
    
    def response
      url               = URI.parse("#{BASE_URL}/#{@action}.json")
      http              = Net::HTTP.new(url.host, url.port)
      http.use_ssl      = true
      http.ca_file      = CA_PATH
      http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
      http.verify_depth = 5
      post              = Net::HTTP::Post.new(url.path)
      parameters = RUBY_VERSION < "1.9" ? normalize_array_params(@parameters) : @parameters
      post.set_form_data(parameters)
      Response.new(http.start { |session| session.request(post) })
    rescue Timeout::Error, Errno::EINVAL,        Errno::ECONNRESET,
           EOFError,       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError => error
      Response.new("error" => error.message)
    end

    private

    def normalize_array_params(params)
      result = []
      params.to_a.each do |k,v|
        case v
        when Array
          v.each do |av|
            result << ["#{k.to_s}[]", av]
          end
        else
          result << [k,v]
        end
      end
      result
    end

  end
end

