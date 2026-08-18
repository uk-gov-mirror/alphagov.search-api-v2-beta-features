namespace :report do
  # Outputs a list of evaluations of GOV.UK site search quality fetched from the Google DiscoveryEngine API's evaluations endpoint.
  # The task can be called with no arguments, or with two arguments.
  # Example usage:
  # rake report:evaluations['2026-06','failed pending'] will fetch pending and failed evaluations created in June 2026.
  # rake report:evaluations['','failed pending'] will fetch all failed and pending evaluations
  # rake report:evaluations['2026-06',''] will fetch all evaluations created in June 2026
  # rake report:evaluations will fetch all evaluations
  desc "Output evaluations report"
  task :evaluations, %i[date_string states] => :environment do |_, args|
    valid_date_regex = /^\d{4}-\d{2}$/

    if args[:date_string]
      date_string = args[:date_string]
      raise "date_string must be in the format yyyy-mm" unless date_string.match(valid_date_regex)
    end

    if args[:states]
      states = split_and_validate_states(args[:states])
    end

    DiscoveryEngine::Quality::EvaluationsReporter.new(date_string:, states:).fetch_and_format
  end

  # Outputs a list of evaluations of GOV.UK site search quality, which have been run during the current month.
  # These are fetched from the Google DiscoveryEngine API's evaluations endpoint.
  # The task can be called with no arguments, or with a string input representing a list of relevant states.
  # Example usage:
  # rake report:evaluations['failed pending'] will fetch all failed and pending evaluations run this month.
  # rake report:evaluations will fetch all evaluations that have been run during the current month.
  desc "Output evaluations report for this month"
  task :evaluations_this_month, %i[states] => :environment do |_, args|
    date_string = Time.zone.now.strftime("%Y-%m")
    states = split_and_validate_states(args[:states])

    DiscoveryEngine::Quality::EvaluationsReporter.new(date_string:, states:).fetch_and_format
  end

  # Outputs a list of evaluations of GOV.UK site search quality, which have been run during the last calendar month.
  # These are fetched from the Google DiscoveryEngine API's evaluations endpoint.
  # The task can be called with no arguments, or with a string input representing a list of relevant states.
  # Example usage:
  # rake report:evaluations['failed pending'] will fetch all failed and pending evaluations run last month.
  # rake report:evaluations will fetch all evaluations that have been run during the last calendar month.
  desc "Output evaluations report for last month"
  task :evaluations_last_month, %i[states] => :environment do |_, args|
    date_string = Time.zone.now.prev_month.strftime("%Y-%m")
    states = split_and_validate_states(args[:states])

    DiscoveryEngine::Quality::EvaluationsReporter.new(date_string:, states:).fetch_and_format
  end
end

def split_and_validate_states(states)
  return unless states

  valid_states = DiscoveryEngine::Quality::EvaluationsReporter::VALID_STATES
  split_states = states.split(" ").map { |arg| arg.upcase.to_sym }
  raise "state must be one of #{valid_states.to_sentence}" unless (split_states - valid_states).empty?

  split_states
end
