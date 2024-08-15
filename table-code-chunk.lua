--- table-code-chunk.lua – converts tables into kable code chunk
---
--- Copyright: © 2024 Abhishek Ulayil
--- License: MIT – see LICENSE for details

-- Makes sure users know if their pandoc version is too old for this
-- filter.
PANDOC_VERSION:must_be_at_least '3.1'
table_count = 1
identifiers = {}
function write_to_file(filename,open_mode,content)
  local file,err = io.open(filename,open_mode)
  if file then
      file:write(content .. "\n")
      file:close()
  else
      print("error:", err)
  end
end

element_switch = {
  Plain = function(el) return parse_content(el.content[1]) end,
  CodeBlock = function(el) return  el.text:gsub("[\n\r]", " ")   end,
  Para = function(el) return el.content end,
  Str = function(el) return string.gsub(el.text,"*","\\*") end,
  Strong = function(el) return [[**]].. parse_content(el.content[1]) .. [[**]] end,
  Emph = function(el) return [[*]] .. parse_content(el.content[1]) .. [[*]] end,
  Strikeout = function(el) return [[~~]] .. parse_content(el.content[1]) .. [[~~]] end,
  Subscript = function(el) return [[~]] .. parse_content(el.content[1]) .. [[~]] end,
  Superscript = function(el) return [[^]] .. parse_content(el.content[1]) .. [[^]] end,
  Code = function(el) return "`" .. el.text .. "`" end,
  Link = function(el) 
    return [[<a href="]] .. el.target .. [[">]] .. parse_content(el.content[1]) .. [[</a>]] 
  end,
  Image = function(el)
    return [[<img src="]] .. el.src .. [[" alt="graphic with alt text"/>]]
  end,
  Math = function(el)
    if (el.mathtype) == "InlineMath" then
      return "$" .. el.text .. "$"
    end
    if (el.mathtype) == "DisplayMath" then
      return "$$" .. el.text .. "$$"
    end
  end
}
function parse_content(data)
  local fun = element_switch[data.tag]
  if (fun) then
    return fun(data)
  else
    return pandoc.utils.stringify(data)
  end
end
function Table(el)
  -- Header Data
  local data_file_name = [[table_data_]] .. table_count .. [[.csv]] 
  local head = el.head.rows
  for i = 1,#head,1 do
    if head[i] ~= nil then
      local row_data = head[i]
      local cell_data = row_data.cells
      local row_text = ""
      for j = 1,#cell_data,1 do
        if cell_data[j] ~= nil then
          local cell_contents = ""
          if cell_data[j].contents[1] == nil  then
            cell_contents = " "
          else
            cell_contents = parse_content(cell_data[j].contents[1]) 
          end
          if j ~= #cell_data then
            row_text = row_text .. cell_contents .. " ,"
          else
            row_text = row_text .. cell_contents
          end
        end
      end
      if i == 1 then
        write_to_file(data_file_name,'w',row_text)
      else 
        write_to_file(data_file_name,'a',row_text)
      end
    end
  end
  -- body content
  local content = el.bodies[1].body
  for i = 1,#content,1 do
    local row_data = content[i]
    local cell_data = row_data.cells
    local row_text = ""
    for j = 1,#cell_data,1 do
      if cell_data[j] ~= nil then
        local cell_contents = ""
        if cell_data[j].contents[1] == nil  then
          cell_contents = " "
        else
          cell_contents = parse_content(cell_data[j].contents[1]) 
        end
        if j ~= #cell_data then
          row_text = row_text .. cell_contents .. " ,"
        else
          row_text = row_text .. cell_contents
        end
      end
    end
    if row_text ~= "" then
      write_to_file(data_file_name,'a',row_text)
    end
  end
  local table_code_block = {}
  table.insert(table_code_block, [[```{r ]] .. [[table-]]..table_count..[[, echo = FALSE, results = 'asis'}]] .. string.char(10))
  table.insert(table_code_block, [[table_]]..table_count..[[_data <- read.csv("]] .. data_file_name .. [[")]] .. string.char(10))
  table.insert(table_code_block, [[knitr::kable(table_]]..table_count..[[_data, caption="]] .. pandoc.utils.stringify(el.caption) .. [[")]] .. string.char(10))
  table.insert(table_code_block, [[```]])
  table_count = table_count + 1
  return pandoc.RawInline('markdown', pandoc.utils.stringify(table_code_block))
end

function sanitize_identifier(identifier)
  local l = identifier
  l = string.gsub(l, "%.", "-")
  l = string.gsub(l, "_", "-")
  l = string.gsub(l, " ", "-")
  l = string.gsub(l,"#","")
  l = string.gsub(l,":","")
  return l
end