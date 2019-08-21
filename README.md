Testing [TuringLang/Turing.jl#869](https://github.com/TuringLang/Turing.jl/issues/869)

Running the following with this package's environment instantiated and activated:

```julia
import PNUTS
PNUTS.run_example()
```

yields the following error (on calling `trendmodel`) in Julia 1.2.0:

```julia
ERROR: StackOverflowError:
Stacktrace:
 [1] convert(::Type{Tuple{Type{Array{Float64,1}}}}, ::Tuple{DataType}) at ./essentials.jl:304 (repeats 3
 times)
 [2] Type at ./tuple.jl:218 [inlined]
 [3] NamedTuple{(:t, :y, :TV),Tuple{Array{Float64,1},Array{Float64,1},Type{Array{Float64,1}}}}(::Tuple{A
rray{Float64,1},Array{Float64,1},DataType}) at ./namedtuple.jl:62 (repeats 37114 times)
 [4] (::getfield(PNUTS, Symbol("#trendmodel#9")){getfield(PNUTS, Symbol("##trendmodel#1#10")),Int64,Floa
t64,Int64,Float64})(::Array{Float64,1}, ::Array{Float64,1}, ::Type) at /home/chrobinson.com/garbsea/.jul
ia/packages/Turing/z32lI/src/core/compiler.jl:412 (repeats 2 times)
 [5] run_example() at /home/chrobinson.com/garbsea/repo/PNUTS/src/example.jl:61
 [6] top-level scope at REPL[2]:1
```

`run_example` is the modified example code from the issue. Turing and AdvancedHMC were pinned to master (2019-08-21).
