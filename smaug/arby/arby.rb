include MatrixFunctions
extend MatrixFunctions

module Arby
	module Attributes
	  def assign!(**kwargs)
	    kwargs.each do |k, v|
	      send("#{k}=".to_sym, v)
	    end
	    self
		end

	  def slice(*attrs)
			attrs.map do |attr|
				[attr, send(attr.to_sym)]
	    end.to_h
		end
	end

	module Vector2
		def clamp(rect)
			vec2(
				x.clamp(rect.x, rect.w + rect.x),
				y.clamp(rect.y, rect.h + rect.y),
			)
		end

		def with_i
			vec2(x.to_i, y.to_i)
		end

		def with_f
			vec2(x.to_f, y.to_f)
		end

		def floor
			vec2(x.floor.to_f, y.floor.to_f)
		end

		def round
			vec2(x.round.to_f, y.round.to_f)
		end

		def *(other)
			vec2(
				(x*other).to_f,
				(y*other).to_f,
			)
		end

		def -(other)
			vec2(
				(x - other.x).to_f,
				(y - other.y).to_f,
			)
		end

		def w
			x
		end

		def w=(other)
			self.x = other
		end

		def h
			y
		end

		def h=(other)
			self.y = other
		end
	end
end

class Array
	def to_json
		insides = map do |v|
			v.to_json
		end.join(", ")
		"[#{insides}]"
	end
end

class Hash
	def to_json
		insides = map do |(k,v)|
			"#{k.to_json}:#{v.to_json}"
		end.join(", ")
		"{#{insides}}"
	end

	def with_syms
		transform_keys do |k|
			k.is_a?(String) ? k.to_sym : k
		end
	end
end

class Symbol
	def to_json
		to_s.inspect
	end
end

class String
	def to_json
		inspect
	end
end

class Object
	def to_json
		inspect
	end

	def try(msg_name, *args, **kwargs)
		if kwargs.any?
			send(msg_name, *args, **kwargs)
		else
			send(msg_name, *args)
		end
	end

	def to_h
		{klass: self.class.name}
	end

	def serialize
		to_h
	end
end

class NilClass
	def to_json
		"null"
	end

	def try(*_args, **_kwargs)
		nil
	end
end
