module Greedy
using Random
Random.seed!(0)

function read_file(instance::String)
    #= file reader 
    #Input:
    instance::String path to the instance
    #Output:
    p::Array{Int,1} processing times of the instance
     =#
    f = open(instance, "r")
    p = Int[]

    for lines in readlines(f)
        line = split(lines)
        for i in 1:length(line)
            push!(p, parse(Int,line[i]))
        end
    end
    return p
end


function algo1(p::Array{Int,1}, t::Int)
    #= Greedy approximation algorithm described in Section IV
    # Input
    p::Array{Int,1} processing times of the instance
    t::Int transportation time from D to M or M to D
    # Output
    Cmax::Int makespan 
    S::Array{Int,1} Indexes of the jobs scheduled =#



    #p sorted in increasing order of processing times
    n = length(p)
    p_remaining = copy(p)
    S = [0 for i in 1:n]
    indexes = [i for i in 2:n-1]
    S[1] = n
    S[n] = 1

    m = [0 for i in 1:n]
    v = [0 for i in 1:n]

    m[1] = t+p[n]
    v[1] = t
    v[2] = 3*t
    v[3] = 5*t

    deleteat!(p_remaining, length(p_remaining))
    deleteat!(p_remaining, 1)



    for i in 2:n-2
        if m[i-1]>=v[i+1]
            mini, arg_mini = min(p_remaining...), argmin(p_remaining)
            S[i] = indexes[arg_mini]
            m[i] = m[i-1] + mini
            deleteat!(p_remaining,arg_mini)
            deleteat!(indexes, arg_mini)
            v[i+2] = m[i-1]+2*t
        else
            if m[i-1]+max(p_remaining...)>=v[i+1]
                j = 1
                diff = v[i+1]-m[i-1]
                while p_remaining[j]<diff
                    j+=1
                end
                S[i] = indexes[j]
                m[i] = m[i-1] + p_remaining[j]
                deleteat!(p_remaining,j)
                deleteat!(indexes, j)
                v[i+2] = v[i+1]+2*t
            else
                S[i] = indexes[1]
                m[i] = m[i-1] + p_remaining[1]
                deleteat!(p_remaining,1)
                deleteat!(indexes, 1)
                v[i+2] = v[i+1]+2*t
            end
        end
    end
    S[n-1] = indexes[1]
    m[n-1] = max(m[n-2],v[n-1])+p_remaining[1]
    Cmax = max(m[n-1],v[n])+p[1]

    return Cmax, S
end


function main()
    p = read_file("instances\\3PP501.txt")
    println(p)
    t = 100
    @time C,S = algo1(p, t)
    
    println(C)
end

main()


#= m = 10
B = 40
p = PP3_instance(m,B)
println(p)

t = Int(B/4) =#

#= t = 10

p = instances_greedy(10, t)
#println(p)
println(algo1(p,t)) =#



end


