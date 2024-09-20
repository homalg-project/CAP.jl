function SSortedList(list::Union{Vector, UnitRange, StepRange})
	unique(sort(list))
end

global const SetGAP = SSortedList

function AddSet(set, element)
	push!(set, element)
	sort!(set)
	unique!(set)
end

function RemoveSet(set, element)
	for i in 1:length(set)
		if set[i] == element
			popat!(set, i)
			return
		end
	end
	error("was not an element")
end

function IsSubset(list1::Vector, list2::Vector)
	issubset(list2, list1)
end

function Difference(set::Vector, subset::Vector)
	sort(setdiff(set, subset))
end

function Difference(set::UnitRange, subset::Vector)
	sort(setdiff(set, subset))
end

function Intersection(set1::Vector, set2::Vector)
	sort(intersect(set1, set2))
end

function UnionGAP(args...)
	if length(args) == 1
		args = args[1]
	end
	if length(args) == 0
		[ ]
	elseif length(args) == 1
		args[1]
	else
		sort(union(args...))
	end
end
