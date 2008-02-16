require 'ostruct'
module Pit
	class Data < OpenStruct
		# for hash like access
		def [] key
			__send__ key
		end
		
		# should be convertable to Hash which has keys that is String instance.
		def to_hash
			unless @to_hash
				result_of = {}
				hash = marshal_dump
				hash.each do |key, val|
					result_of[key.to_s] = val
				end
				
				@to_hash = result_of
			end
			
			@to_hash
		end
		
		def to_yaml
			to_hash.to_yaml
		end
	end
end
