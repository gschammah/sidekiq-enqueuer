# frozen_string_literal: true

class NoParamWorker
  include Sidekiq::Job

  def perform; end
end

class HardWorker
  include Sidekiq::Job

  def perform(param1, param2); end
end

class HardJob < ActiveJob::Base
  queue_as :default

  def perform(param1, param2); end
end

class WorkerWithPerformAsync
  include Sidekiq::Job

  def perform_async(param1, param2); end
end

class WorkerWithNoParams
  include Sidekiq::Job

  def perform; end
end

class WorkerWithKeyValueParams
  include Sidekiq::Job

  def perform(required_param:, optional_param: nil, optional_param2: nil); end
end

class WorkerWithOptionalParams
  include Sidekiq::Job

  def perform(required_param, optional_param = nil, optional_param2 = nil); end
end

class WorkerWithDefinedQueue
  include Sidekiq::Job

  sidekiq_options queue: :custom_queue

  def perform; end
end

class JobWithKeywordParams < ActiveJob::Base
  queue_as :default

  def perform(country, max_created_at: nil, dry_run: false); end
end

class WorkerWithSplat
  include Sidekiq::Job

  def perform(*args); end
end
