-- Checks if we're on the beginning of a new line
local line_begin = require("luasnip.extras.expand_conditions").line_begin

-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
local get_visual = function(args, parent)
	if #parent.snippet.env.LS_SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
	else -- If LS_SELECT_RAW is empty, return a blank insert node
		return sn(nil, i(1))
	end
end

-- Function to detect math environment
local in_mathzone = function()
	-- The `in_math` function requires the VimTeX plugin
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

-- Function to detect text environment
local in_text = function()
	return not in_mathzone()
end

local in_comment = function()
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end

local in_env = function(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

local in_tikz = function()
	return in_env("tikzpicture")
end

return {
	-- A snippet that expands the trigger "hi" into the string "Hello, world!".
	s({ trig = "hi" }, { t("Hello, world!") }),

	s(
		{ trig = "([^%a])ff", regTrig = true, wordTrig = false, condition = in_mathzone, snippetType = "autosnippet" },
		fmta([[<>\frac{<>}{<>}]], {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		})
	),

	s(
		{
			trig = "begin",
			dscr = "environment",
		},
		fmta(
			[[
        \begin{<>}
          <>
        \end{<>}
      ]],
			{ i(1), i(0), rep(1) }
		)
	),

	s(
		{ trig = "([^%a])mm", wordTrig = false, regTrig = true, snippetType = "autosnippet", condition = in_text },
		fmta("<>$<>$", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		})
	),

	-- Subscript expansions for 0, 1, 2
	s(
		{
			trig = "([%a%)%]%}])00",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = in_mathzone,
		},
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("0"),
		})
	),
	s(
		{
			trig = "([%a%)%]%}])11",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = in_mathzone,
		},
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("1"),
		})
	),
	s(
		{
			trig = "([%a%)%]%}])22",
			regTrig = true,
			wordTrig = false,
			snippetType = "autosnippet",
			condition = in_mathzone,
		},
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("2"),
		})
	),

	s({ trig = "tt", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\text{<>}]], { i(1) })),
	s({ trig = "tii", snippetType = "autosnippet" }, fmta([[\textit{<>}]], { i(1) })),
	s({ trig = "tbb", snippetType = "autosnippet" }, fmta([[\textbf{<>}]], { i(1) })),
	s({ trig = "...", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\dots]], {})),

	s(
		{ trig = "h1", dscr = "Top-level section", snippetType = "autosnippet" },
		fmta([[\section{<>}]], { i(1) }),
		{ condition = line_begin } -- set condition in the `opts` table
	),

	s(
		{ trig = "new", dscr = "A generic new environmennt", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{<>}
            <>
        \end{<>}
      ]],
			{
				i(1),
				i(2),
				rep(1),
			}
		),
		{ condition = line_begin }
	),

	s(
		{ trig = "sum", snippetType = "autosnippet", condition = in_mathzone },
		fmta([[\sum\limits_{<>}<>]], { i(1), i(0) })
	),
	s(
		{
			trig = "(%w+)%^(%w+)%s",
			snippetType = "autosnippet",
			wordTrig = true,
			regTrig = true,
			condition = in_mathzone,
		},
		fmta([[<>^{<>}]], {
			f(function(_, snip)
				return snip.captures[1]
			end),
			f(function(_, snip)
				return snip.captures[2]
			end),
		})
	),

	s(
		{ trig = "([^%s|$]+)//", snippetType = "autosnippet", wordTrig = true, regTrig = true, condition = in_mathzone },
		fmta([[\frac{<>}{<>}]], {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		})
	),

	s({ trig = "inn", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\in]], {})),
	s(
		{ trig = "NN", snippetType = "autosnippet", wordTrig = false, condition = in_mathzone },
		fmta([[\mathbb{N}]], {})
	),
	s({ trig = "RR", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\mathbb{R}]], {})),
	s({ trig = "CC", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\mathbb{C}]], {})),
	s({ trig = "FF", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\mathbb{F}]], {})),

	s(
		{ trig = "(%w)nn", snippetType = "autosnippet", condition = in_mathzone },
		fmta([[<>_{n}]], { f(function(_, snip)
			return snip.captures[1]
		end) })
	),
	s(
		{ trig = "(%w)mm", snippetType = "autosnippet", condition = in_mathzone },
		fmta([[<>_{mm}]], { f(function(_, snip)
			return snip.captures[1]
		end) })
	),

	s(
		{ trig = "tikz", snippetType = "autosnippet", condition = in_tikz },
		fmta(
			[[
        \begin{tikzpicture}
          <>
        \end{tikzpicture}
      ]],
			{ i(0) }
		)
	),

	s({ trig = ">=", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\geq]], {})),
	s({ trig = "<=", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\leq]], {})),

	s(
		{ trig = "(%w+)_", snippetType = "autosnippet", wordTrig = true, regTrig = true, condition = in_mathzone },
		fmta([[<>_{<>}]], {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		})
	),

	-- s({ trig = })

	s({ trig = "**", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\cdot]], {})),
	s({ trig = "abs", snippetType = "autosnippet", condition = in_mathzone }, fmta([[\abs{<>}<>]], { i(1), i(0) })),
}
