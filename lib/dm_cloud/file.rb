require 'net/http/post/multipart'

module DmCloud
  class File
    def self.upload
      call_type = 'file.upload'

      params = {
        call: call_type,
        args: {}
      }
      DmCloud.config[:auto_call] == true ? DmCloud::Request.execute(call_type, params) : {call: call_type, params: params}
    end

    def self.send_file(url, fd)
      uri = URI.parse(url)

      req = Net::HTTP::Post::Multipart.new uri.request_uri, "file" => UploadIO.new(fd, 'video/mp4', ::File.basename(fd))
      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end
    end
  end
end