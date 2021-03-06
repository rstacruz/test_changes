require 'spec_helper'

require 'test_changes/client'

describe TestChanges::Client do
  subject(:client) do
    described_class.new(
      test_tool_command: 'rspec',
      finding_patterns: [
        TestChanges::FindingPattern.new(
          matching_pattern: %r{^lib/(.+)\.rb},
          substitution_patterns: ['spec/\1_spec.rb']
        ),
        TestChanges::FindingPattern.new(
          matching_pattern: %r{^spec/(.+)_spec.rb},
          substitution_patterns: ['spec/\1_spec.rb']
        )
      ],
      commit: commit,
      test_tool_call_options: test_tool_call_options,
      verbose: false
    )
  end

  describe "#call" do
    let(:git_diff_call) do
      "git diff --name-only --diff-filter=AMR #{expected_commit}"
    end

    let(:changed_file_path) { 'lib/test_changes/client.rb' }

    let(:test_tool_command) { 'rspec' }

    let(:matching_file_path) { 'spec/test_changes/client_spec.rb' }

    let(:test_tool_call) do
      "#{test_tool_command} #{matching_file_path}"
    end

    context "where the commit is the only argument" do
      let(:test_tool_call_options) { [] }

      let(:commit) { 'HEAD^' }
      let(:expected_commit) { commit }

      it "runs the test tool on tests matching files changed since that commit" do
        expect(subject)
          .to receive(:`).with(git_diff_call)
          .and_return(changed_file_path)

        expect(subject).to receive(:system).with(test_tool_call)

        expect(File).to receive(:exist?).with(matching_file_path).and_return(true)

        client.call
      end
    end

    context "where the arguments are the test tool options and the commit" do
      let(:option) { '--format=documentation' }
      let(:test_tool_call_options) { [option] }

      let(:commit) { 'HEAD^' }
      let(:expected_commit) { commit }

      let(:test_tool_call) do
        "#{test_tool_command} #{option} #{matching_file_path}"
      end

      it "runs the test tool on tests matching files changed since that commit" do
        expect(subject)
          .to receive(:`).with(git_diff_call)
          .and_return(changed_file_path)

        expect(subject).to receive(:system).with(test_tool_call)

        expect(File).to receive(:exist?).with(matching_file_path).and_return(true)

        client.call
      end
    end
  end
end
