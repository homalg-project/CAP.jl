.PHONY: test

gen:
	gap_to_julia CAP

clean-gen:
	rm -f ./src/gap/*.autogen.jl
	rm -f ./src/gap/*/*.autogen.jl
	rm -f ./docs/src/*.autogen.md
	gap_to_julia CAP

test:
	julia -e 'using Pkg; Pkg.test("CAP");'

codecov:
	julia --project=. -e 'using Coverage; using Pkg; Pkg.test(coverage=true); LCOV.writefile("coverage.lcov", process_folder(pwd()));'
	genhtml -o coverage_report coverage.lcov
	open coverage_report/index.html

clean-codecov:
	find . -type f -name "*.jl.*.cov" -exec rm -f {} +
	rm -f coverage.lcov
	rm -rf coverage_report
