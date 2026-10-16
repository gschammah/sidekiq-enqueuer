# Sidekiq Enqueuer Changes
3.0.0
-----------

- Requires Sidekiq 8 (8.0 and 8.1) and Ruby 3.2+. The Web tab registers through `Sidekiq::Web.configure`.
- Keyword parameters are passed as kwargs to ActiveJob. Sidekiq jobs with keyword parameters, splats or blocks are refused with a message.
- Form values are typed: `true`/`false`, `nil`, integers, floats and JSON. Quoted text stays a String. Blank fields are left out so method defaults apply.
- Missing required params, invalid JSON and a blank or non-positive delay re-render the form with an error and keep the input.
- Unknown jobs return 404.
- A flash confirms the enqueued args and jid, or says the job was not enqueued (for example a unique job that is already queued).
- Auto-detected jobs skip anonymous classes instead of failing to sort.
- Views restyled for Sidekiq 8, which dropped Bootstrap.

2.2.1
-----------

- Fixed utils namespacing.
- Setup github workflows to take care of static code analysis, specs and coverage.
- Added contribution guidelines and code of conduct.
- Transferred all the contribution credits to umbrellio.

2.2.0
-----------

- Possibility to pass jobs as string/symbol literals to avoid const resolving at initialize step.
- Set up the project up to maintain good code quality.
- Minor refactoring.

2.1.0
-----------

- Minor patches & improvements.

2.0.0
-----------

- Version bump to stable after rollout to prod.


2.1.0.beta
-----------
- Drop support for Yaml-like params
- Added support for required and optional parameters based on the method definition
- Fixed issue with nil parameters being send to Jobs as `nil` strings
- Added New Exception to be raised when Required Param values are not present

2.0.0.beta
-----------

- Added configuration option: Provides a list of Jobs to display
- Dropped support for manual 'unlock'
- Sidekiq enqueuing now uses `Sidekiq::Client.enqueue_to / enqueue_to_in` to a custom queue.
- Refactor on classes and modules to bring Atomicity


1.0.6
-----------

- Jobs are sorted by name by default


1.0.4
-----------

- Support for jobs without arguments


1.0.3
-----------

- Support unlock! for sidekiq-middleware
