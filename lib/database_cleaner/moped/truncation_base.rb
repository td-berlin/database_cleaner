require 'database_cleaner/moped/base'
require 'database_cleaner/generic/truncation'

module DatabaseCleaner
  module Moped
    module TruncationBase
      include ::DatabaseCleaner::Moped::Base
      include ::DatabaseCleaner::Generic::Truncation

      def clean
        if @only
          collections.each { |c| session[c].find.remove_all if @only.include?(c) }
        else
          collections.each { |c| session[c].find.remove_all unless @tables_to_exclude.include?(c) }
        end
        true
      end

      private

      def collections
        if db != :default
          session.use(db)
        end

        if db_version.split('.').first.to_i >= 3
          session.command(listCollections: 1)['cursor']['firstBatch'].map do |collection|
            collection['name']
          end
          .reject do |collection_name|
            collection_name =~ /.?system\.|\$/
          end
        else
          session['system.namespaces'].find(name: { '$not' => /\.system\.|\$/ }).to_a.map do |collection|
            _, name = collection['name'].split('.', 2)
            name
          end
        end
      end

    end
  end
end
