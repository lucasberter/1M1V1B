module generator
using Random
Random.seed!(0)

function PP3_instance(m::Int, t::Int)
    #= # instances created following the transformation of section III
    # Inputs: 
    m::Int number of sequences of 3 jobs 
    t::Int transportation time from D to M or M to D
    # Output
    p::Array{Int,1} array of 4*m+1 processing times =#
    B = t*4
    p = [0 for i in 1:4*m+1]


    B_2 = B/2-2
    B_4 = B/4+1
    k = 1
    for i in 1:m
        a = Int(rand(B_4:B_2))
        p[k] = a

        b = Int(rand(B_4:3*B/4-a-1))
        p[k+1] = b

        c = B-a-b
        p[k+2] = c
        k+=3
    end

    for i in 0:m
        p[k+i] = B
    end

    p[length(p)]=0
    sort!(p)
    str = ""
    for i in 1:length(p)
        str*= " "*string(p[i])
    end
    open("3PP"*string(4*m+1)*".txt", "w") do file
        write(file,str)
    end
    return p
end

function instances_greedy(n::Int, t::Int; e1 = 2, e2 = 1)
    #= # instances created following the worst case for 
                    the greedy algorithm of section IV
    # Inputs: 
    n::Int number of sequences of 5 jobs 
    t::Int transportation time from D to M or M to D
    e1::Int a small integer
    e2::Int a small integer(smaller than e1)
    # Output
    p::Array{Int,1} array of 5*n processing times =#

    p = [0 for i in 1:n*5]

    for i in 1:n*2
        p[i] = 4*t-e1
    end

    for i in 1:n*3
        p[n*2+i] = e2
    end

    sort!(p)
    str = ""
    for i in 1:length(p)
        str*= " "*string(p[i])
    end
    open("worst"*string(n*5)*".txt", "w") do file
        write(file,str)
    end

    return p
end


function random_gen(n::Int, t::Int)
    #= # instances created with random processing times
            generated using an uniform distribution between
            1 and 2t
    # Inputs: 
    n::Int number of jobs
    t::Int transportation time from D to M or M to D

    # Output
    p::Array{Int,1} array of n processing times =#
    p = rand(1:2*t,n)
    sort!(p)
    str = ""
    for i in 1:length(p)
        str*= " "*string(p[i])
    end
    open("random"*string(n)*".txt", "w") do file
        write(file,str)
    end
    return p
end

t = 100
instances_greedy(100,t)



end