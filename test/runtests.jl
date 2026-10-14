using Test, Documenter, CAP

# doctest only the (comma-separated) docs/src files named in DOCTEST_FILES,
# or all .md files in docs/src if unset, so CI can split doctests across several jobs
# To test a subset locally, run: DOCTEST_FILES=file_1.md,file_2.md make test
docs_src = joinpath(pkgdir(CAP), "docs", "src")
files_env = get(ENV, "DOCTEST_FILES", "")
files = isempty(files_env) ? sort(filter(f -> endswith(f, ".md"), readdir(docs_src))) : split(files_env, ',')

@info "Doctesting" files

mktempdir() do dir
    for f in files
        cp(joinpath(docs_src, f), joinpath(dir, f))
    end
    doctest(dir, [CAP])
end
