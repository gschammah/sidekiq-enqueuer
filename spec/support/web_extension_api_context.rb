# frozen_string_literal: true

RSpec.shared_context "web extension api context" do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do
      use Rack::Session::Cookie, secret: "1" * 64, same_site: :lax
      run Sidekiq::Web
    end
  end

  # Sidekiq 8.1 checks Sec-Fetch-Site instead of a CSRF token; 8.0 uses the token.
  before { header "Sec-Fetch-Site", "same-origin" }

  # Sidekiq 8.0 rotates the CSRF token after every POST, so read a fresh one each time.
  def csrf_token(path = "/enqueuer")
    get path
    last_response.body[/name='authenticity_token' value='([^']+)'/, 1]
  end

  def post_form(job_class_name, perform: {}, submit: "Enqueue", enqueue_in: nil)
    params = {
      "authenticity_token" => csrf_token("/enqueuer/#{job_class_name}"),
      "job_class_name" => job_class_name,
      "perform" => perform,
      "submit" => submit,
    }
    params["enqueue_in"] = enqueue_in unless enqueue_in.nil?
    post "/enqueuer", params
  end

  def flash_message
    get "/enqueuer"
    last_response.body[%r{<p class="flash">(.*?)</p>}m, 1]
  end
end
