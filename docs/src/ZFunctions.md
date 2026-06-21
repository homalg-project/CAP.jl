```jldoctest ZFunctions
julia> using CAP

julia> seq = AsZFunction(i -> i^2);

julia> seq
<ZFunction>

julia> seq[0]
0

julia> seq[3]
9

julia> seq[-5]
25

julia> upper_func = function(a)
           if a[2] != 0
               return [a[2], a[1] % a[2]]
           end
           return a
       end;

julia> lower_func = identity;

julia> gcd_seq = ZFunctionWithInductiveSides(0, [111, 259], lower_func, upper_func, ==);

julia> gcd_seq
<ZFunction>

julia> HasStableLowerValue(gcd_seq)
false

julia> gcd_seq[-1]
2-element Vector{Int64}:
 111
 259

julia> HasStableLowerValue(gcd_seq)
true

julia> StableLowerValue(gcd_seq)
2-element Vector{Int64}:
 111
 259

julia> IndexOfStableLowerValue(gcd_seq)
0

julia> gcd_seq[0]
2-element Vector{Int64}:
 111
 259

julia> gcd_seq[1]
2-element Vector{Int64}:
 259
 111

julia> gcd_seq[2]
2-element Vector{Int64}:
 111
  37

julia> gcd_seq[3]
2-element Vector{Int64}:
 37
  0

julia> HasStableUpperValue(gcd_seq)
false

julia> gcd_seq[4]
2-element Vector{Int64}:
 37
  0

julia> HasStableUpperValue(gcd_seq)
true

julia> StableUpperValue(gcd_seq)
2-element Vector{Int64}:
 37
  0

julia> IndexOfStableUpperValue(gcd_seq)
3

julia> total = ApplyMap(gcd_seq, Sum);

julia> total[0]
370

julia> total[100]
37

julia> c = CombineZFunctions([gcd_seq, total]);

julia> c[0]
2-element Vector{Any}:
    [111, 259]
 370

```
