mod_minus_pi_to_pi(a::T) where {T} = mod2pi(a + pi) - pi

"""
    principal_value(R::Rotation{3})

Returns the principal value of a rotation. The result depends on rotation type:
Quat: non-negative real part
SPQuat: norm of components between 0 and 1 inclusive
AngleAxis: angle between 0 and pi inclusive
RodriguesVec: angle between 0 and pi inclusive
RotX, RotXY, etc: all angles between -pi and pi inclusive
"""
principal_value(r::RotMatrix) = r
principal_value(q::Quat{T}) where {T} = q.w < zero(T) ? Quat{T}(-q.w, -q.x, -q.y, -q.z) : q
principal_value(spq::SPQuat{T}) where {T} = convert(SPQuat, principal_value(convert(Quat, spq)))

function principal_value(aa::AngleAxis{T}) where {T}
    theta = mod_minus_pi_to_pi(aa.theta)
    if theta < zero(T)
        return AngleAxis(-theta, -aa.axis_x, -aa.axis_y, -aa.axis_z)
    else
        return AngleAxis( theta,  aa.axis_x,  aa.axis_y,  aa.axis_z)
    end
end

function principal_value(rv::RodriguesVec{T}) where {T}
    theta = rotation_angle(rv)
    if pi < theta
        re_s = mod_minus_pi_to_pi(theta) / theta
        return RodriguesVec(re_s * rv.sx, re_s * rv.sy, re_s * rv.sz)
    else
        return rv
    end
end

for rot_type in [:RotX, :RotY, :RotZ]
    @eval begin
        function principal_value(r::$rot_type{T}) where {T}
            return $(rot_type){T}(mod_minus_pi_to_pi(r.theta))
        end
    end
end

for rot_type in [:RotXY, :RotYX, :RotZX, :RotXZ, :RotYZ, :RotZY]
    @eval begin
        function principal_value(r::$rot_type{T}) where {T}
            theta1 = mod_minus_pi_to_pi(r.theta1)
            theta2 = mod_minus_pi_to_pi(r.theta2)
            return $(rot_type){T}(theta1, theta2)
        end
    end
end

for rot_type in [:RotXYX, :RotYXY, :RotZXZ, :RotXZX, :RotYZY, :RotZYZ, :RotXYZ, :RotYXZ, :RotZXY, :RotXZY, :RotYZX, :RotZYX]
    @eval begin
        function principal_value(r::$rot_type{T}) where {T}
            theta1 = mod_minus_pi_to_pi(r.theta1)
            theta2 = mod_minus_pi_to_pi(r.theta2)
            theta3 = mod_minus_pi_to_pi(r.theta3)
            return $(rot_type){T}(theta1, theta2, theta3)
        end
    end
end
