require 'test_changes/error'

module TestChanges
  class InferredConfig
    attr_reader :finding_patterns_map
    attr_reader :test_tool_command
    attr_reader :config_path

    def initialize
      if File.exists?('./config/application.rb')
        if File.exists?('./bin/rspec')
          return use_rspec_rails('./bin/rspec')
        elsif File.directory?('./spec')
          return use_testunit_rails('bundle exec rspec')
        elsif File.directory?('./test')
          return use_testunit_rails('bundle exec ruby -Itest')
        end
      end

      raise TestChanges::Error.new("No .test_changes.yaml found")
    end

    def finding_patterns
      FindingPattern.build finding_patterns_map
    end

    def verbose
      true
    end

  private

    def use_rspec_rails(bin)
      @config_path = '[inferred: rspec_rails]'
      @test_tool_command = bin
      @finding_patterns_map = {
        '^app/(models)/(.+).rb' => 'spec/\1/\2_spec.rb',
        '^app/(controller|helper|view)s/(.+).rb' => 'spec/controllers/\2_\1_spec.rb'
      }
    end

    def use_testunit_rails(bin)
      @config_path = '[inferred: testunit_rails]'
      @test_tool_command = bin
      @finding_patterns_map = {
        '^app/(models)/(.+).rb' => 'test/\1/\2_test.rb',
        '^app/(controller|helper|view)s/(.+).rb' => 'test/controllers/\2_\1_test.rb'
      }
    end
  end
end