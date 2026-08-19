RSpec.describe "Report tasks" do
  let(:reporter) { instance_double(DiscoveryEngine::Quality::EvaluationsReporter) }

  before do
    task.reenable
    allow(DiscoveryEngine::Quality::EvaluationsReporter)
      .to receive(:new)
      .with(anything)
      .and_return(reporter)
    allow(reporter).to receive(:fetch_and_format)
  end

  describe "report:evaluations" do
    let(:task) { Rake::Task["report:evaluations"] }

    it "does not require arguments" do
      expect { task.invoke }.not_to raise_error
    end

    it "raises an error if date string is not formatted correctly" do
      expect { task.invoke("2027-1") }.to raise_error(RuntimeError)
    end

    it "raises an error if the states are not valid" do
      expect { task.invoke("", "invalid") }.to raise_error(RuntimeError)
    end
  end

  describe "report:evaluations_this_month" do
    let(:task) { Rake::Task["report:evaluations_this_month"] }

    around do |example|
      Timecop.freeze(2026, 2, 8) { example.call }
    end

    it "does not require arguments" do
      expect { task.invoke }.not_to raise_error
    end

    it "calls evaluations reporter for this month" do
      task.invoke

      expect(DiscoveryEngine::Quality::EvaluationsReporter)
        .to have_received(:new)
        .with(date_string: "2026-02", states: nil)
    end

    it "raises an error if the states are not valid" do
      expect { task.invoke("invalid") }.to raise_error(RuntimeError)
    end
  end

  describe "report:evaluations_last_month" do
    let(:task) { Rake::Task["report:evaluations_last_month"] }

    around do |example|
      Timecop.freeze(2026, 2, 8) { example.call }
    end

    it "does not require arguments" do
      expect { task.invoke }.not_to raise_error
    end

    it "calls evaluations reporter for last month" do
      task.invoke

      expect(DiscoveryEngine::Quality::EvaluationsReporter)
        .to have_received(:new)
        .with(date_string: "2026-01", states: nil)
    end

    it "raises an error if the states are not valid" do
      expect { task.invoke("invalid") }.to raise_error(RuntimeError)
    end
  end
end
