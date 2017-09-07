"""
    perpendicular_vector(vec)

Compute a vector perpendicular to `vec` by switching the two elements with
largest absolute value, flipping the sign of the second largest, and setting the
remaining element to zero.
"""
function perpendicular_vector(vec::SVector{3})
    T = eltype(vec)

    # find indices of the two elements of vec with the largest absolute values:
    absvec = abs.(vec)
    ind1 = indmax(absvec) # index of largest element
    @inbounds absvec2 = @SVector [ifelse(i == ind1, typemin(T), absvec[i]) for i = 1 : 3] # set largest element to typemin(T)
    ind2 = indmax(absvec2) # index of second-largest element

    # perp[ind1] = -vec[ind2], perp[ind2] = vec[ind1], set remaining element to zero:
    @inbounds perpind1 = -vec[ind2]
    @inbounds perpind2 = vec[ind1]
    perp = @SVector [ifelse(i == ind1, perpind1, ifelse(i == ind2, perpind2, zero(T))) for i = 1 : 3]
end

"""
    angle_difference(a, b)

Compute the difference between two angles in such a way that:
* for angles `a` and `b` (in radians), and `c = angle_difference(a, b)`, `cos(a) ≈ cos(b + c)` and `sin(a) ≈ sin(b + c)`;
* the result is in the interval [-π, π).
"""
angle_difference(a, b) = mod2pi(a - b + π) - π
