

struct LazyHVector{D, F}
	domain::D
	func::F
	values::Vector{Any}
	evaluated::BitVector
end

function LazyHVector(domain::D, func::F) where {D, F}
	n = length(domain)
	LazyHVector(domain, func, Vector{Any}(undef, n), falses(n))
end

Base.length(L::LazyHVector) = length(L.domain)

function Base.getindex(L::LazyHVector, i::Int)
	if !L.evaluated[i]
		L.values[i] = L.func(L.domain[i])
		L.evaluated[i] = true
	end
	L.values[i]
end

function Base.getindex(L::LazyHVector, I::Vector)
	[L[i] for i in I]
end

Base.iterate(L::LazyHVector, state=1) = state > length(L) ? nothing : (L[state], state + 1)

function show(io::IO, L::LazyHVector)
	print("LazyHList of length ", length(L), " and evaluated values: [")
	if any(L.evaluated)
		for i in 1:length(L)
			if L.evaluated[i]
				print(io, " ")
				show(io, L.values[i])
			end
			if i < length(L)
				print(io, ",")
			end
		end
	end
	print(" ]")
end

function ListOfValues(L::LazyHVector)
	[L[i] for i in 1:length(L)]
end
