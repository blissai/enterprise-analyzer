module AwsUploader
  def upload_to_aws(bucket, key, content)
    conn = Faraday.new(url: "http://#{bucket}.s3.amazonaws.com") do |faraday|
      faraday.request :multipart
      faraday.adapter :net_http
    end
    conn.put("/#{key}", content) do |req|
      req.headers['x-amz-acl'] = 'bucket-owner-read'
    end
  end
end
