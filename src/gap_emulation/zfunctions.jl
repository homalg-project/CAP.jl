# Julia emulation of GAP's IsZFunction / IsZFunctionWithInductiveSides
# (ToolsForHomalg/gap/ZFunctions.g*)

mutable struct ZFunction
	underlying_function::Union{Function, Nothing}
	# Stable upper value: for all i >= index_of_stable_upper_value, value is stable_upper_value
	has_stable_upper_value::Bool
	stable_upper_value::Any
	index_of_stable_upper_value::Int
	# Stable lower value: for all i <= index_of_stable_lower_value, value is stable_lower_value
	has_stable_lower_value::Bool
	stable_lower_value::Any
	index_of_stable_lower_value::Int
	# Extra read-only attributes for ZFunctionWithInductiveSides (nothing for plain ZFunction)
	is_inductive::Bool
	starting_index::Union{Int, Nothing}
	starting_value::Any
	upper_function::Union{Function, Nothing}
	lower_function::Union{Function, Nothing}
	compare_function::Union{Function, Nothing}
	# Extra read-only attributes for ApplyMap
	base_z_functions::Union{Vector, Nothing}
	applied_map::Union{Function, Nothing}
end

# -- Constructors --

function VoidZFunction()
	ZFunction(nothing, false, nothing, 0, false, nothing, 0, false, nothing, nothing, nothing, nothing, nothing, nothing, nothing)
end

function AsZFunction(func::Function)
	ZFunction(func, false, nothing, 0, false, nothing, 0, false, nothing, nothing, nothing, nothing, nothing, nothing, nothing)
end

function ZFunctionWithInductiveSides(N::Int, value_N, lower_func::Function, upper_func::Function, compare_func::Function)
	z = ZFunction(nothing, false, nothing, 0, false, nothing, 0, true, N, value_N, upper_func, lower_func, compare_func, nothing, nothing)
	
	func = function(i::Int)
		if i == N
			return value_N
		elseif i > N
			if z.has_stable_upper_value
				return z.stable_upper_value
			else
				prev_value = z[i - 1]
				value = upper_func(prev_value)
				if compare_func(value, prev_value)
					SetStableUpperValue(z, i - 1, value)
				end
				return value
			end
		else  # i < N
			if z.has_stable_lower_value
				return z.stable_lower_value
			else
				prev_value = z[i + 1]
				value = lower_func(prev_value)
				if compare_func(value, prev_value)
					SetStableLowerValue(z, i + 1, value)
				end
				return value
			end
		end
	end
	
	z.underlying_function = func
	return z
end

# -- Attribute accessors --

function UnderlyingFunction(z::ZFunction)
	z.underlying_function
end

function HasStableUpperValue(z::ZFunction)
	z.has_stable_upper_value
end

function StableUpperValue(z::ZFunction)
	z.stable_upper_value
end

function IndexOfStableUpperValue(z::ZFunction)
	z.index_of_stable_upper_value
end

function HasStableLowerValue(z::ZFunction)
	z.has_stable_lower_value
end

function StableLowerValue(z::ZFunction)
	z.stable_lower_value
end

function IndexOfStableLowerValue(z::ZFunction)
	z.index_of_stable_lower_value
end

function StartingIndex(z::ZFunction)
	z.starting_index
end

function StartingValue(z::ZFunction)
	z.starting_value
end

function UpperFunction(z::ZFunction)
	z.upper_function
end

function LowerFunction(z::ZFunction)
	z.lower_function
end

function CompareFunction(z::ZFunction)
	z.compare_function
end

function HasBaseZFunctions(z::ZFunction)
	z.base_z_functions !== nothing
end

function BaseZFunctions(z::ZFunction)
	z.base_z_functions
end

function AppliedMap(z::ZFunction)
	z.applied_map
end

# -- Setters --

function SetStableUpperValue(z::ZFunction, n::Int, val)
	z.stable_upper_value = val
	z.has_stable_upper_value = true
	z.index_of_stable_upper_value = n
end

function SetStableLowerValue(z::ZFunction, n::Int, val)
	z.stable_lower_value = val
	z.has_stable_lower_value = true
	z.index_of_stable_lower_value = n
end

# -- Evaluation --

function Base.getindex(z::ZFunction, i::Int)
	if z.has_stable_lower_value && i <= z.index_of_stable_lower_value
		return z.stable_lower_value
	end
	if z.has_stable_upper_value && i >= z.index_of_stable_upper_value
		return z.stable_upper_value
	end
	z.underlying_function(i)
end

function ZFunctionValue(z::ZFunction, i::Int)
	z[i]
end

# -- Operations --

# Apply a function f to each index-wise tuple of values from a list of ZFunctions.
# Emulates: AsZFunction( i -> CallFuncList( f, List( z_functions, z -> z[i] ) ) )
function ApplyMap(z_functions::Vector, f::Function)
	z = AsZFunction(i -> f([ zf[i] for zf in z_functions ]...))
	z.base_z_functions = z_functions
	z.applied_map = f
	return z
end

function ApplyMap(z_function::ZFunction, f::Function)
	ApplyMap([z_function], f)
end

# Combine a list of ZFunctions into one returning a list of values at each index.
# Emulates: ApplyMap( L, function( arg ) return arg; end )
function CombineZFunctions(L::Vector)
	ApplyMap(L, (args...) -> collect(args))
end

# Return a ZFunction whose value at i is z[-i].
function Reflection(z::ZFunction)
	AsZFunction(i -> z[-i])
end

# Return a ZFunction equal to z except at indices n..n+length(L)-1 where values come from L.
function Replace(z::ZFunction, n::Int, L::Vector)
	AsZFunction(function(i::Int)
		if n <= i <= n + length(L) - 1
			L[i - n + 1]
		else
			z[i]
		end
	end)
end

# Return a ZFunction whose value at i is z[i + n].
function ApplyShift(z::ZFunction, n::Int)
	AsZFunction(i -> z[i + n])
end

# -- Display --

function Base.show(io::IO, ::ZFunction)
	print(io, "<ZFunction>")
end

function ViewString(z::ZFunction)
	"<ZFunction>"
end
