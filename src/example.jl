using Turing, Random, CSV, DataFrames

function run_example()
    Random.seed!(12)

    # Reproducing the pymc3 implementation found here:
    # https://www.ritchievink.com/blog/2018/10/09/build-facebooks-prophet-in-pymc3-bayesian-time-series-analyis-with-generalized-additive-models/

    # downloaded from https://raw.githubusercontent.com/facebook/prophet/master/examples/example_wp_log_peyton_manning.csv
    url = "https://raw.githubusercontent.com/facebook/prophet/master/examples/example_wp_log_peyton_manning.csv"
    p = joinpath("data", basename(url))

    if !isfile(p)
        mkpath(dirname(p))
        download(url, p)
    end
    df = CSV.read(p)

    df[!, :yscale] = df[!, :y] ./ maximum(df[!, :y])

    min_ds, max_ds = extrema(df.ds)
    df[!, :t] = (df.ds - min_ds) / (max_ds - min_ds)

    # plot(df.ds, df.yscale)

    nchangepoints = 10

    # Proportion of history in which trend changepoints will be estimated.
    changepoints_range = .8
    # The standard deviation of the prior on the growth.
    growth_prior_scale = 5
    # The scale of the Laplace prior on the delta vector.
    changepoints_prior_scale = .05

    @model trendmodel(t, y, ::Type{TV}=Vector{Float64}) where TV = begin  # <= CHANGED
        # num observations
        nobs = length(t)
        s =  collect(range(1, stop=nobs*changepoints_range, length=nchangepoints))
        A = [(t[i] >= s[j])*1 for i=1:nobs, j=1:nchangepoints]

        k ~ Normal(0.0, growth_prior_scale)

        # rate of change
        delta = TV(undef, nchangepoints)  # <= CHANGED
        delta ~ [Laplace(0.0, changepoints_prior_scale)]

        # offset
        m ~ Normal(0.0, 5.0)

        gamma = -s.*delta

        g = (k .+ A*delta).*t + (m .+ A * gamma)

        # The number of observations.
        sd ~ Truncated(Cauchy(0.0, .5), 0.000001, Inf)
        for n in 1:nobs
            y[n] ~ Normal(g[n], sd)
        end
    end

    model = trendmodel(df.t, df.yscale)

    chain = sample(model, NUTS(1500, 200, 0.65), progress=true);
end
