module Mongoid
  module Document
    module ClassMethods
      def all_full_json
        collection.find.to_json
      end
      def find_full_json(criteria)
        if criteria.is_a? String
          criteria = {_id: BSON::ObjectId.from_string(criteria)}
        end
        collection.find(criteria).first.to_json
      end
    end
  end
end