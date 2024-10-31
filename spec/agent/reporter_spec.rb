# encoding: utf-8
# frozen_string_literal: true

require "support/mock_rails"

RSpec.describe OasAgent::Agent::Reporter do
  before do
    stub_const("Rails", MockRails)
    MockRails.reset

    # Ensure we have default config in place
    OasAgent::AgentContext.config.integrate(OasAgent::Agent::Configuration::DefaultSource.new.to_h)

    stub_const("TestReporter", Class.new(OasAgent::Agent::Reporter))
  end

  after do
    OasAgent::AgentContext.config.clear
  end

  describe ".instance" do
    it "returns the same object" do
      object1 = TestReporter.instance
      object2 = TestReporter.instance

      expect(object1.object_id).to be(object2.object_id)
    end
  end

  describe "#close" do
    let(:reporter_thread) { TestReporter.instance.instance_variable_get(:@reporter_thread) }
    let(:report_queue) { TestReporter.instance.instance_variable_get(:@report_queue) }

    it "stops processing reports nicely" do
      TestReporter.instance.close

      expect(report_queue).to be_closed if report_queue.respond_to?(:closed)
      expect(reporter_thread).not_to be_alive
    end

    context "with a reporter thread slow to stop" do
      let(:slow_thread) { Thread.new { sleep 10 } }

      after { slow_thread.kill if slow_thread.alive? }

      it "kills the thread after a timeout" do
        # Setup logger so we can check the warning appears
        logger = Class.new do
          def messages
            @messages ||= []
          end

          def warn(message)
            messages << [:warn, message]
          end
        end

        OasAgent::AgentContext.logger = logger.new

        # Swap the reporter thread for a "slow" one
        # Stop us leaking the original thread in test
        reporter_thread.kill
        slow_thread = Thread.new { sleep 10 }
        TestReporter.instance.instance_variable_set(:@reporter_thread, slow_thread)

        TestReporter.instance.close

        expect(OasAgent::AgentContext.logger.messages).to include([:warn, "Timeout joining report thread during shutdown"])
        expect(report_queue).to be_closed if report_queue.respond_to?(:closed)
      end
    end
  end

  context "when send_immediately is true" do
    before do
      OasAgent::AgentContext.config.integrate(reporter: {send_immediately: true})
    end

    it "does not create background thread" do
      TestReporter.instance
      expect(TestReporter.instance.instance_variable_get(:@reporter_thread)).to be_nil
    end

    describe "#close" do
      context "with send immediately enabled" do
        before do
          OasAgent::AgentContext.config.integrate(reporter: {send_immediately: true})
        end

        it "happily closes down" do
          TestReporter.instance.close

          expect(TestReporter.instance.instance_variable_get(:@reporter_thread)).to be_nil
          q = TestReporter.instance.instance_variable_get(:@report_queue)
          if q.respond_to?(:closed)
            expect(q.closed?).to be(true)
          end
        end
      end
    end

    describe "#restart" do
      it "does not create background thread" do
        TestReporter.instance.restart

        expect(TestReporter.instance.instance_variable_get(:@reporter_thread)).to be_nil
      end
    end
  end
end
