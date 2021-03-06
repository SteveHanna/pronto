class BitbucketClient
  include HTTParty
  base_uri 'https://api.bitbucket.org/1.0/repositories'

  def initialize(username, password)
    @credentials = { username: username, password: password }
    @headers = { basic_auth: @credentials }
  end

  def commit_comments(slug, sha, options = {})
    options.merge!(@headers)
    response = self.class.get("/#{slug}/changesets/#{sha}/comments", options)
    openstruct(response.parsed_response)
  end

  def create_commit_comment(slug, sha, body, path, position, _ = nil, _ = nil, options = {})
    options.merge!(@headers)
    options[:body] = {
      content: body,
      line_to: position,
      filename: path
    }
    self.class.post("/#{slug}/changesets/#{sha}/comments", options)
  end

  def pull_comments(slug, pr_id, options = {})
    options.merge!(@headers)
    response = self.class.get("/#{slug}/pullrequests/#{pr_id}/comments", options)
    openstruct(response.parsed_response)
  end

  def pull_requests(slug, options = {})
    options.merge!(@headers)
    response = self.class.get("https://api.bitbucket.org/2.0/repositories/#{slug}/pullrequests?state=OPEN", options)
    openstruct(response.parsed_response['values'])
  end

  def create_pull_comment(slug, pull_id, body, _, path, position, options = {})
    options.merge!(@headers)
    options[:body] = {
      content: body,
      line_to: position,
      filename: path
    }
    self.class.post("/#{slug}/pullrequests/#{pull_id}/comments", options)
  end

  def openstruct(response)
    response.map { |r| OpenStruct.new(r) }
  end
end
