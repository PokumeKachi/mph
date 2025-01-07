local raw = io.open('src/data.txt', 'r')

local MAX_DIGIT_SPACING = 8

math.randomseed(os.time())

function check_key_page_break(question_index)
  if question_index % 300 == 0 then
    keys = keys..' </div class="keys"> <div class="page-break"/> <div class="keys"> '
  elseif question_index % 10 == 0 then
    keys = keys..string.rep(' <hr/> ', 1)
  end
end

function GetRandomElements(tbl, num, word)
  local result = {word}
  local indices = {}

  if num > #tbl then
    num = #tbl
  end

  while #result < num do
    local index = math.random(1, #tbl)

    if not indices[index] and tbl[index] ~= word then
      table.insert(result, tbl[index])
      indices[index] = true
    end
  end

  return result
end

function ReturnRandomTable(t)
  local newt = {}
  local i = 1
  repeat
    local rand = math.random(1,#t)
    newt[i] = t[rand]
    table.remove(t, rand)
    i = i + 1
  until #t == 0

  return newt
end

local function white_space_remover(word)
  START = 1
  END = string.len(word)

  while string.sub(word, START, START) == ' ' do
    START = START + 1
  end

  while string.sub(word, END, END) == ' ' do
    END = END - 1
  end

  return string.sub(word, START, END)
end

if not raw then
  print('Could not open files.')
  os.exit()
end

local words = {}
local questions = {}
local types = {}
local word_types = {}

local question_mode = false

local set_questions = {}

local function line_process(line)
  local yea = ''

  local stack = false

  for i=1,#line do
    local v = string.sub(line,i,i)

    if v == '_' then
      if not stack then
        stack = true

        if string.sub(line,#yea - 2,#yea - 1) == ' a' then
          yea = string.sub(yea,1,#yea - 2)..'a(n) '
        end

        if string.sub(line,#yea - 3,#yea - 1) == ' an' then
          yea = string.sub(yea,1,#yea - 3)..'a(n) '
        end
      end
    else
      stack = false
    end

    yea = yea..v
  end

  return yea
end

for line in raw:lines() do
  if (string.len(line) == 0) or string.sub(line,1,1) == '#' then
    goto continue
  end

  if line == '=[' then
    question_mode = true
  end

  if line == ']=' then
    question_mode = false
  end

  if line == '&&&' then
    break
  end

  if question_mode == true then
    local content = string.sub(line, 3, string.len(line))

    if string.sub(line,1,1) == '-' then
      table.insert(set_questions,{
        content = content,
        answers = {},
      })
    end

    if string.sub(line,1,1) == '+' then
      table.insert(set_questions[#set_questions].answers,content)

      if string.sub(line,2,2) == '+' then
        set_questions[#set_questions].answer = #set_questions[#set_questions].answers
      end
    end

    goto continue
  end

  if string.sub(line,1, 1) == '=' then
    local type = string.sub(line, 3, string.len(line))
    word_types[words[#words]] = type

    if not types[type] then
      types[type] = {}
    end

    table.insert(types[type], words[#words])
  elseif string.sub(line, 1, 1) == '-' then
    line = line_process(line)

    if questions[words[#words]] == nil then
      questions[words[#words]] = '- '..string.sub(line, 3, string.len(line))
    else
      questions[words[#words]] = questions[words[#words]]..'<br/>'..'- '..string.sub(line, 3, string.len(line))
    end
  else
    table.insert(words, line)
  end

  ::continue::
end

words = ReturnRandomTable(words)


print(
[[
<!DOCTYPE html>
<html>
<head>
</head>
<body>
]]
)

local question_index = 0
local i = 0

keys = ""

for _, word in ipairs(words) do
  i = i + 1

  if not questions[word] then
    goto continue
  end

  question_index = question_index + 1

  local index = 4 * math.floor((i - 1) / 4)

  print('<div class="question">')
  print(tostring(question_index)..'. '..questions[word])
  print('</div>')

  print('<div class="grid-container">')

  local answers = GetRandomElements(types[word_types[words[i]]], 4, words[i])
  answers = ReturnRandomTable(answers)

  for ascii, answer in ipairs(answers) do
    if answer == words[i] then
      local digits = #tostring(question_index)

      keys = keys..tostring(question_index)..''..string.char(64 + ascii)..string.rep(' &nbsp; ', MAX_DIGIT_SPACING - digits)

      check_key_page_break(question_index)
    end
  end

  local j = 1

  for _, answer in ipairs(answers) do
    print('<div class="grid-item">')
    print(string.char(64 + j)..'. '..answer)
    print('</div class="grid-item">')
    j = j + 1
  end

  print('</div class="grid-container">')

  --print('<br/>')


  ::continue::
end

for _,question in ipairs(set_questions) do
  i = i + 1
  question_index = question_index + 1

  local digits = #tostring(question_index)

  print('<div class="question">')
  print(tostring(question_index)..'. '..question.content)
  print('</div>')

  print('<div class="grid-container">')

  --local answers = ReturnRandomTable(question.answers)

  local j = 1

  for _, answer in ipairs(question.answers) do
    print('<div class="grid-item">')
    print(string.char(64 + j)..'. '..answer)
    print('</div class="grid-item">')
    j = j + 1
  end

  print('</div class="grid-container">')

  keys = keys..tostring(question_index)..''..string.char(64 + question.answer)..string.rep(' &nbsp; ', MAX_DIGIT_SPACING - digits)

  check_key_page_break(question_index)
end

print(
[[
</body>
</html>
]]
)

raw:close()

print('<div class="keys">')
print(keys)
print('</div class="keys">')
