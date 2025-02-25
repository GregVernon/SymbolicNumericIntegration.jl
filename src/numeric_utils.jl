
rms(x) = sqrt(sum(x .^ 2) / length(x))

"""
    returns a list of the indices of a linearly independent subset of the columns of A
"""
function find_independent_subset(A; abstol = 1e-3)
    Q, R = qr(A)
    abs.(diag(R)) .> abstol
end

function test_point(complex_plane, radius)
    if complex_plane
        return radius * sqrt(rand()) * cis(2π * rand())
    else
        return Complex(radius * (2 * rand() - 1))
    end
end

accept_solution(eq::ExprCache, x, sol, radius) = accept_solution(expr(eq), x, sol, radius)

function accept_solution(eq, x, sol, radius)
    try
        x₀ = test_point(true, radius)
        Δ = substitute(expand_derivatives(Differential(x)(sol) - eq), Dict(x => x₀))
        return abs(Δ)
    catch e
        #
    end
    return Inf
end

"""
    converts float to int or small rational numbers
"""

function nice_parameter(u::Complex{T}; abstol = 1e-6) where {T <: Real}
    α = nice_parameter(real(u); abstol)
    β = nice_parameter(imag(u); abstol)
    return β ≈ 0 ? α : Complex(α, β)
end

nice_parameter(x; abstol = 1e-6) = small_rational(x; abstol)

nice_parameters(p; abstol = 1e-6) = nice_parameter.(p; abstol)

function small_rational(x::T; abstol = 1e-6, M = 20) where {T <: Real}
    a = floor(Int, x)
    r = x - a
    for den in 2:M
        try
            if abs(round(r * den) - r * den) < abstol
                s = a + round(Int, r * den) // den
                return (denominator(s) == 1 ? numerator(s) : s)
            end
        catch e
        end
    end
    return x
end

###############################################################################

function fibonacci_spiral(n, i)
    ϕ = (1 + sqrt(5)) / 2
    θ, r = mod((i - 1) / ϕ, 1), (i - 1) / n
    sqrt(r) * cis(2π * θ)
end
