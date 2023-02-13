module plne
ENV["GUROBI_HOME"] = "C:\\gurobi952\\win64"

using JuMP, Gurobi
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





function plne2m_ac(p::Array{Int,1},t::Int)
    #= MILP formulation described in section II 
    # Input
    p::Array{Int,1} processing times of the instance
    t::Int transportation time from D to M or M to D

    # Output
    Cmax::Int makespan 
    finished::JUMP.termination_status termination_status at the time limit or before 
    t2::Float64 time spent on the resolution =#
    
    model = Model(Gurobi.Optimizer)
    set_optimizer(model, optimizer_with_attributes(Gurobi.Optimizer, "TimeLimit" => 600.0))
    set_silent(model)
    nb_jobs = length(p)
    M=10000

    @variable(model, c[1:nb_jobs]>=0)
    @variable(model, r[1:nb_jobs]>=0)
    @variable(model, b[1:nb_jobs]>=0)
    @variable(model, v[1:nb_jobs]>=0)

    @variable(model, 0<=x[1:nb_jobs, 1:nb_jobs]<=1,Int)


    @variable(model, Cmax>=0)

    @objective(model, Min, Cmax)


    @constraint(model,[i=1:nb_jobs], Cmax-c[i]>=0)
    @constraint(model,[i=1:nb_jobs], c[i]-r[i]>=p[i])
    @constraint(model,[i=1:nb_jobs], r[i]-b[i]>=0)
    @constraint(model,[i=1:nb_jobs], b[i]-v[i]>=t)

    @constraint(model,[i=1:nb_jobs,j=1:nb_jobs,i!=j], v[j]-b[i]-x[i,j]*M>=t-M)
    @constraint(model,[i=1:nb_jobs,j=1:nb_jobs,i!=j], b[j]-r[i]-x[i,j]*M>=-M)
    @constraint(model,[i=1:nb_jobs,j=1:nb_jobs,i!=j], r[j]-c[i]-x[i,j]*M>=-M)
    @constraint(model,[i=1:nb_jobs,j=i+1:nb_jobs], x[i,j]+x[j,i]==1)
    ti = time()
    optimize!(model)
    t2 = time()-ti

    finished = termination_status(model)
    print(finished)
    Cmax = 0
    if termination_status(model) == OPTIMAL
        Cmax = objective_value(model)
    elseif termination_status(model) == TIME_LIMIT && has_values(model)
        Cmax = objective_value(model)
    else
        Cmax = 0
    end

    return Cmax, finished, t2

end




function main()
    #"3PP49","3PP101","3PP201","3PP501""3PP9","random10","random50",
    #"random100", "random200", "random500"
    l_instances = ["worst10","worst50","worst100","worst500"]
    for i in l_instances
        p = read_file("instances\\"*i*".txt")
        println(i)
        println(p)
        t = 100
        Cmax, finished, time = plne2m_ac(p,t)
        if Cmax == 0
            Cmax = "-"
        end
        str = i*" "*string(Cmax)*" "*string(finished)*" "*string(time)*" "
        open("resultats_MILP.txt", "a") do file
            write(file,str)
        end
    end
    
end

main()
end
