table-code-chunk
==================================================================

[![GitHub build status][CI badge]][CI workflow]

Convert LaTeX / pandoc table stucture into kable code chunk for Rmarkdown

[CI badge]: https://img.shields.io/github/actions/workflow/status/Abhi-1U/table-code-chunk/ci.yaml?branch=main
[CI workflow]: https://github.com/Abhi-1U/table-code-chunk/actions/workflows/ci.yaml


Usage
------------------------------------------------------------------



### Plain pandoc

Pass the filter to pandoc via the `--lua-filter` (or `-L`) command
line option.

    pandoc --lua-filter table-code-chunk.lua ...



License
------------------------------------------------------------------

This pandoc Lua filter is published under the MIT license, see
file `LICENSE` for details.
