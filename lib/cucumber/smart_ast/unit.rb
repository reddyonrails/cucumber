require 'cucumber/ast/tags'
require 'cucumber/smart_ast/result'

module Cucumber
  module SmartAst
    class Unit 
      attr_reader :steps, :language

      def initialize(steps, tags, language)
        @steps, @language = steps, language
        @tags = tags.map { |tag| "@#{tag.name}" }
      end
      
      def accept_hook?(hook)
        Cucumber::Ast::Tags.matches?(@tags, hook.tag_name_lists)
      end
      
      def fail!(exception)
        puts "Unit failed!"
        raise exception
      end
      
      def skip_step_execution!
        @skip = true
      end

      def execute(step_mother, &block)
        step_mother.before_and_after(self) do
          steps.each do |step|
            if @skip
              yield Result.new(:skipped, step)
            else
              yield step_mother.execute(step)
            end
          end
        end
      end
    end
  end
end
