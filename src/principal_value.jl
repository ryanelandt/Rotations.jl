mod_minus_pi_to_pi(a::T) where {T} = mod2pi(a + pi) - pi

"""
    principal_value(R::Rotation{3})

**Background:** All non `RotMatrix` rotation types can represent the same `RotMatrix` in two or more ways. Sometimes a
particular set of numbers is better conditioned (e.g. `SPQuat`) or obeys a particular convention (e.g. `AngleAxis` has
non-negative rotation). In order to preserve differentiability it is necessary to allow rotation representations to
travel slightly away from the nominal domain; this is critical for applications such as optimization or dynamics.

This function takes a rotation type (e.g. `Quat`, `RotXY`) and outputs a new rotation of the same type that corresponds
to the same `RotMatrix`, but that obeys certain conventions or is better conditioned. The outputs of the function have
the following properties:

- all angles are between between `-pi` to `pi` (except for `AngleAxis` which is between `0` and `pi`).
- all `Quat` have non-negative real part
- the components of all `SPQuat` have a norm that is at most 1.
- the `RodriguesVec` rotation is at most `pi`

"""
principal_value(r::RotMatrix) = r
principal_value(q::Quat{T}) where {T} = q.w < zero(T) ? Quat{T}(-q.w, -q.x, -q.y, -q.z) : q
principal_value(spq::SPQuat{T}) where {T} = SPQuat(principal_value(Quat(spq)))

function principal_value(aa::AngleAxis{T}) where {T}
    theta = mod_minus_pi_to_pi(aa.theta)
    if theta < zero(T)
        return AngleAxis(-theta, -aa.axis_x, -aa.axis_y, -aa.axis_z, false)
    else
        return AngleAxis( theta,  aa.axis_x,  aa.axis_y,  aa.axis_z, false)
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
