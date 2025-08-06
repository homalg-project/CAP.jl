using Test, Documenter, CAP

# test upto whitespaces
doctest(CAP; doctestfilters=[r"\s+" => ""])
