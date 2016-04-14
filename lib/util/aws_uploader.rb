module AwsUploader
  def upload_to_aws(bucket, key, content, tried = 0)
    begin
      conn = Faraday.new(url: "http://#{bucket}.s3.amazonaws.com") do |faraday|
        faraday.request :multipart
        faraday.adapter :net_http
      end
      conn.put("/#{key}", content) do |req|
        req.headers['x-amz-acl'] = 'bucket-owner-read'
      end
    rescue Faraday::TimeoutError
      if tried < 3
        sleep 2**tried
        upload_to_aws(bucket, key, content, tried + 1)
      else
        raise "Could not connect to AWS. Connection timed out. Tried #{tried} times.".red
      end
    end
  end
end
