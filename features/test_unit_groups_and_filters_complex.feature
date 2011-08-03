@test_unit
Feature: Sophisticated grouping and filtering on Test/Unit

  Defining groups and filters can be done by passing blocks or strings.
  Blocks get each SimpleCov::SourceFile instance passed an can use arbitrary
  and potentially weird conditions to remove files from the report or add them
  to specific groups.

  Scenario: 
    Given I cd to "project"
    Given a file named "test/simplecov_config.rb" with:
      """
      require 'simplecov'
      SimpleCov.start do
        add_group 'By block' do |src_file|
          src_file.filename =~ /MaGiC/i
        end
        add_group 'By string', 'project/meta_magic'

        add_filter 'faked_project.rb'
        # Remove all files that include "describe" in their source
        add_filter {|src_file| src_file.lines.any? {|line| line.src =~ /TestCase/ } }
        add_filter {|src_file| src_file.covered_percent < 100 }
      end
      """

    When I successfully run `bundle exec rake test`
    Then a coverage report should have been generated

    Given I open the coverage report
    Then I should see the groups:
      | name      | coverage | files |
      | All Files | 100.0%   | 1     |
      | By block  | 100.0%   | 1     |
      | By string | 100.0%   | 1     |

    And I should see the source files:
      | name                              | coverage |
      | ./lib/faked_project/meta_magic.rb | 100.0 %  |