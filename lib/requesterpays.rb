class RequesterPays < Seahorse::Client::Plugin
  handler(step: :initialize) do |context|
    if context.params.delete(:requester_pays)
      context.http_request.headers['x-amz-request-payer'] = 'requester'
    end
    @handler.call(context)
  end
end
