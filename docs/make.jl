using Documenter
using HandyG

makedocs(
    sitename = "HandyG.jl",
    modules = [HandyG],
    doctest = false,
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Installation" => "man/installation.md",
            "Calling Conventions" => "man/calling.md",
            "i0 Prescription" => "man/i0.md",
            "Batch API" => "man/batch.md",
            "Runtime Options" => "man/options.md",
            "Performance Notes" => "man/performance.md",
        ],
        "API Reference" => "api.md",
        "References" => "literature.md",
    ],
)

